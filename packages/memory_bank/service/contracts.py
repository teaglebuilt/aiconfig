from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

class AddMemoryReq(BaseModel):
    content: str
    kind: Optional[str] = None
    scope: Optional[str] = None
    project: Optional[str] = None
    repo: Optional[str] = None
    rel_path: Optional[str] = None
    tags: Optional[List[str]] = None
    pinned: bool = False
    ttl_sec: Optional[int] = None


class AddMemoryResp(BaseModel):
    id: str
    hash: str
    upserted: bool

class QueryReq(BaseModel):
    q: str = Field(..., description="Natural language / keyword query")
    limit: int = 20
    rerank: bool = True
    # Simple filters (exact-match). Extend as needed.
    filters: Optional[Dict[str, Any]] = None  # {project, repo, kind, scope, pinned, after, before, tags_any}


class QueryResp(BaseModel):
    items: List[Dict[str, Any]]
