from typing import List, TypedDict, Optional
import pyarrow as pa

class MemoryRecord(TypedDict):
    id: str
    source: str
    project: str
    role: str
    text: str
    embedding: Optional[List[float]]
    timestamp: float
    metadata: dict

memory_schema = pa.schema([
    ("id", pa.string()),
    ("source", pa.string()),
    ("project", pa.string()),
    ("role", pa.string()),
    ("text", pa.string()),
    ("embedding", pa.list_(pa.float32())),
    ("timestamp", pa.float64()),
    ("metadata", pa.map_(pa.string(), pa.string()))
])
