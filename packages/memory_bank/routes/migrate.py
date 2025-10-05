from fastapi import APIRouter, Depends, HTTPException
from typing import List, Dict, Any, Iterable
import hashlib
import datetime as dt
from contracts import ImportSpec, RawItemsImport
from vector_store import tbl, EMBEDDER, ImportedRow
from server import auth


class Adapter:
  name: str
  def load(self, **kwargs) -> Iterable[ImportedRow]:
    raise NotImplementedError

ADAPTERS: Dict[str, Adapter] = {}

migrate_router = APIRouter(tags=["migrate"])


@migrate_router.post("/import")
async def import_from_source(spec: ImportSpec, _: None = Depends(auth)):
  adapter = ADAPTERS.get(spec.source)
  if not adapter:
    raise HTTPException(400, f"Unknown source '{spec.source}'")

  rows: List[Dict[str, Any]] = []
  vectors_batch: List[List[float]] = []

  def canonical_hash(content: str, meta: Dict[str, Any]) -> str:
    bits = [content.strip(), meta.get("external_source"), meta.get("external_id"), meta.get("project"), ",".join(sorted(meta.get("tags") or []))]
    s = "\u241F".join([x or "" for x in bits])
    return hashlib.blake2b(s.encode("utf-8"), digest_size=16).hexdigest()


  for item in adapter.load(path=spec.path, project=spec.project, default_tags=spec.default_tags, channel_tag=spec.channel_tag):
    meta = item.model_dump()
    content = meta.pop("content")
    # derive hash/id if missing
    h = meta.get("hash") or canonical_hash(content, meta)
    rid = meta.get("id") or h
    now = dt.datetime.utcnow()
    row = {
      "id": rid,
      "hash": h,
      "content": content,
      "created_at": meta.get("created_at") or now,
      "updated_at": now,
      **{k: v for k, v in meta.items() if k not in {"id", "hash", "vector"}},
    }
    rows.append(row)


# Batch embed via ONNX if requested and available
  if spec.use_onnx and EMBEDDER.available():
    contents = [r["content"] for r in rows]
    vectors_batch = EMBEDDER.embed(contents)
    for r, vec in zip(rows, vectors_batch):
      r["vector"] = vec


# Upsert in chunks
    CHUNK = 1024
    total = 0
    for i in range(0, len(rows), CHUNK):
      batch = rows[i:i+CHUNK]
      (
        tbl.merge_insert("hash")
        .when_matched_update_all()
        .when_not_matched_insert_all()
        .execute(batch)
      )
      total += len(batch)
  return {"ok": True, "imported": total, "source": spec.source}


@migrate_router.post("/import/items")
async def import_raw_items(body: RawItemsImport, _: None = Depends(auth)):
  rows: List[Dict[str, Any]] = []
  now = dt.datetime.utcnow()
  for item in body.items:
    row = {
      "id": item.id,
      "hash": item.hash,
      "content": item.content,
      "created_at": item.created_at,
      "updated_at": now,
      **{k: v for k, v in item.model_dump().items() if k not in {"id", "hash", "vector"}},
    }