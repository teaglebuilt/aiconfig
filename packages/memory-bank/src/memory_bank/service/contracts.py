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
    filters: Optional[Dict[str, Any]] = None


class QueryResp(BaseModel):
    items: List[Dict[str, Any]]


class ImportSpec(BaseModel):
    source: str = Field(..., description="Adapter source key, e.g., 'jsonl'")
    path: Optional[str] = Field(None, description="Path to import from (if applicable)")
    project: Optional[str] = None
    default_tags: Optional[List[str]] = None
    channel_tag: Optional[str] = None
    use_onnx: bool = False


class RawItem(BaseModel):
    id: str
    hash: str
    content: str
    project: Optional[str] = None
    repo: Optional[str] = None
    rel_path: Optional[str] = None
    kind: Optional[str] = None
    scope: Optional[str] = None
    tags: Optional[List[str]] = None
    pinned: bool = False
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    ttl_sec: Optional[int] = None


class RawItemsImport(BaseModel):
    items: List[RawItem]
