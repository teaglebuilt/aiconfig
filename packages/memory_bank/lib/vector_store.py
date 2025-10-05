import os
import datetime as dt
from typing import List, Optional, Dict, Any
from pydantic import Field
from lancedb.pydantic import LanceModel, Vector
from lancedb.embeddings import get_registry
import pyarrow as pa
import lancedb

GM_DB = os.getenv("GM_DB", os.path.expanduser("~/.global-memory/lancedb"))
GM_TABLE = os.getenv("GM_TABLE", "memory")

EMBED_FAMILY = os.getenv("GM_EMBED_FAMILY", "sentence-transformers")
EMBED_MODEL = os.getenv("GM_EMBED_MODEL", "BAAI/bge-small-en-v1.5")
EMBED_DEVICE = os.getenv("GM_EMBED_DEVICE", "cpu")

embed_func = get_registry().get(EMBED_FAMILY).create(name=EMBED_MODEL, device=EMBED_DEVICE)

os.makedirs(GM_DB, exist_ok=True)
db = lancedb.connect(GM_DB)

class MemoryRow(LanceModel):
    id: str
    hash: str
    content: str = embed_func.SourceField()
    vector: Vector(embed_func.ndims()) = embed_func.VectorField()
    kind: Optional[str] = None  # note | adr | link | action | file | etc.
    scope: Optional[str] = None  # global | project | repo
    project: Optional[str] = None
    repo: Optional[str] = None
    rel_path: Optional[str] = None
    tags: Optional[List[str]] = None
    pinned: bool = False
    created_at: dt.datetime = Field(default_factory=lambda: dt.datetime.utcnow())
    updated_at: dt.datetime = Field(default_factory=lambda: dt.datetime.utcnow())
    ttl_sec: Optional[int] = None


class ImportedRow(LanceModel):
    id: Optional[str] = None # if omitted we derive from hash
    hash: Optional[str] = None # if omitted we derive from canonical content
    content: str
    vector: Optional[Vector()] = None # allow precomputed vectors; else LanceDB embeds
    kind: Optional[str] = None
    scope: Optional[str] = None
    project: Optional[str] = None
    repo: Optional[str] = None
    rel_path: Optional[str] = None
    tags: Optional[List[str]] = None
    pinned: bool = False
    created_at: Optional[dt.datetime] = None
    updated_at: Optional[dt.datetime] = None
    ttl_sec: Optional[int] = None
    external_source: Optional[str] = None # 'notion' | 'obsidian' | 'slack' | 'github' | 'jsonl' | ...
    external_id: Optional[str] = None # provider's id or stable slug
    external_url: Optional[str] = None
    author: Optional[str] = None
    created_at_orig: Optional[dt.datetime] = None
    metadata: Optional[Dict[str, Any]] = None


try:
    tbl = db.open_table(GM_TABLE)
except Exception:
    tbl = db.create_table(GM_TABLE, schema=MemoryRow)


def ensure_indexes() -> None:
    """Create helpful indexes (ignore if they already exist)."""
    # Vector ANN index
    try:
        tbl.create_index(metric="cosine", vector_column_name="vector")
    except Exception:
        pass
    # Full-text index on the content column (BM25)
    try:
        tbl.create_fts_index("content")
    except Exception:
        pass
    # Scalar indexes to accelerate filters & upserts
    for col in ("hash", "project", "repo", "kind", "scope", "pinned", "created_at"):
        try:
            tbl.create_scalar_index(col)
        except Exception:
            pass


def ensure_extended_schema() -> None:
    """Evolve the table with missing columns if upgrading from the base schema."""
    existing = {f.name for f in tbl.schema}
    add_cols: List[pa.Field] = []

    def _need(name: str, dt_: pa.DataType):
        if name not in existing:
            add_cols.append(pa.field(name, dt_))

    _need("external_source", pa.string())
    _need("external_id", pa.string())
    _need("external_url", pa.string())
    _need("author", pa.string())
    _need("created_at_orig", pa.timestamp("us"))
    _need("metadata", pa.map_(pa.string(), pa.large_string()))
    if add_cols:
        tbl.add_columns(add_cols)
        for c in ["external_source", "external_id", "hash"]:
            try:
                tbl.create_scalar_index(c)
            except Exception:
                pass
        try:
            tbl.create_fts_index("content")
        except Exception:
            pass
    return tbl