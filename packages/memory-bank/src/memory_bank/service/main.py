from __future__ import annotations

import os
import hashlib
import datetime as dt
from typing import Any, Dict, List, Optional

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from lancedb.rerankers import RRFReranker

from memory_bank.service.contracts import (
    AddMemoryReq,
    AddMemoryResp,
    QueryReq,
    QueryResp,
)
from memory_bank.settings import get_settings
from memory_bank.vector_store import tbl, ensure_indexes, GM_TABLE, ensure_extended_schema
from memory_bank.service.guards import auth

GM_API_KEY = os.getenv("GM_API_KEY")

ensure_indexes()

app = FastAPI(title="Global Memory (LanceDB)", version="0.2.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
ensure_extended_schema()


def _canonicalize_for_hash(payload: AddMemoryReq) -> str:
    parts: List[str] = [payload.content or ""]
    for k in ("kind", "scope", "project", "repo", "rel_path"):
        parts.append(str(getattr(payload, k) or ""))
    if payload.tags:
        parts.append("|".join(sorted([t.lower() for t in payload.tags])))
    parts.append(str(payload.pinned))
    return "\u241F".join(parts)  # unit separator


def _build_where(filters: Optional[Dict[str, Any]]) -> Optional[str]:
    if not filters:
        return None
    clauses: List[str] = []

    def esc(v: str) -> str:
        return v.replace("'", "''")

    if (v := filters.get("project")):
        clauses.append(f"project = '{esc(v)}'")
    if (v := filters.get("repo")):
        clauses.append(f"repo = '{esc(v)}'")
    if (v := filters.get("kind")):
        clauses.append(f"kind = '{esc(v)}'")
    if (v := filters.get("scope")):
        clauses.append(f"scope = '{esc(v)}'")
    if (v := filters.get("pinned")) is not None:
        clauses.append("pinned IS TRUE" if bool(v) else "pinned IS FALSE")

    # Created/updated ranges (ISO8601 or 'YYYY-MM-DD')
    if (v := filters.get("after")):
        clauses.append(f"created_at >= timestamp '{esc(v)}'")
    if (v := filters.get("before")):
        clauses.append(f"created_at <= timestamp '{esc(v)}'")

    # Tags OR filter using DataFusion array function
    tags_any = filters.get("tags_any")
    if tags_any:
        arr = ", ".join([f"'{esc(t)}'" for t in tags_any])
        # requires DataFusion array_has_any; supported in LanceDB filter engine
        clauses.append(f"array_has_any(tags, array[{arr}])")

    return " AND ".join(clauses) if clauses else None

# ------------ Routes ------------
@app.get("/health")
def health() -> Dict[str, Any]:
    return {"ok": True, "table": GM_TABLE, "rows": tbl.count_rows()}


@app.post("/v1/memory", response_model=AddMemoryResp)
def add_memory(body: AddMemoryReq, _: None = Depends(auth)):
    now = dt.datetime.utcnow()
    canonical = _canonicalize_for_hash(body)
    h = hashlib.blake2b(canonical.encode("utf-8"), digest_size=16).hexdigest()
    rid = h  # stable id derived from canonical hash

    record: Dict[str, Any] = {
        "id": rid,
        "hash": h,
        "content": body.content,
        "kind": body.kind,
        "scope": body.scope,
        "project": body.project,
        "repo": body.repo,
        "rel_path": body.rel_path,
        "tags": body.tags,
        "pinned": bool(body.pinned),
        "ttl_sec": body.ttl_sec,
        "created_at": now,
        "updated_at": now,
    }
    (
        tbl.merge_insert("hash")
        .when_matched_update_all()
        .when_not_matched_insert_all()
        .execute([record])
    )

    return AddMemoryResp(id=rid, hash=h, upserted=True)


@app.post("/v1/memory/query", response_model=QueryResp)
def query_memory(body: QueryReq, _: None = Depends(auth)):
    where = _build_where(body.filters)
    # Hybrid search = semantic (vector) + BM25 FTS on content
    q = tbl.search(
        body.q,
        query_type="hybrid",
        vector_column_name="vector",
        fts_columns="content",
    )

    if where:
        q = q.where(where)

    if body.rerank:
        q = q.rerank(RRFReranker())

    rows: List[Dict[str, Any]] = q.limit(body.limit).to_list()

    # Strip embedding vector from payload if present
    def _clean(row: Dict[str, Any]) -> Dict[str, Any]:
        row.pop("vector", None)
        return row

    return QueryResp(items=[_clean(r) for r in rows])


@app.post("/v1/memory/{rid}/pin")
def pin_memory(rid: str, _: None = Depends(auth)):
    tbl.update(where=f"id = '{rid.replace("'","''")}'", values={"pinned": True, "updated_at": dt.datetime.utcnow()})
    return {"id": rid, "pinned": True}


@app.post("/v1/memory/{rid}/unpin")
def unpin_memory(rid: str, _: None = Depends(auth)):
    tbl.update(where=f"id = '{rid.replace("'","''")}'", values={"pinned": False, "updated_at": dt.datetime.utcnow()})
    return {"id": rid, "pinned": False}


@app.delete("/v1/memory/{rid}")
def delete_memory(rid: str, _: None = Depends(auth)):
    tbl.delete(where=f"id = '{rid.replace("'","''")}'")
    return {"id": rid, "deleted": True}


@app.post("/admin/reindex")
def rebuild_indexes(_: None = Depends(auth)):
    ensure_indexes()
    return {"ok": True}


def main() -> None:  # pragma: no cover
    import uvicorn

    settings = get_settings()
    uvicorn.run(
        "memory_bank.service.main:app",
        host=settings.GM_API_HOST,
        port=settings.GM_API_PORT,
        reload=settings.GM_API_RELOAD,
        reload_dirs=[settings.GM_API_RELOAD_DIR] if settings.GM_API_RELOAD else None,
    )


if __name__ == "__main__":  # pragma: no cover
    main()
