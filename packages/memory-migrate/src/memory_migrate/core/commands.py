from pathlib import Path

from datamodel_code_generator import DataModelType, generate

from memory_migrate.adapters import openai
from memory_migrate.embed.onnx_runtime import OnnxEmbedder
from memory_migrate.storage import duckdb_store


def export_memory(adapter: str, source_path: str):
    """Generate Pydantic models from JSON export file."""
    output_path = Path(f"memory_migrate/adapters/{adapter}_models.py")
    generate(
        output=output_path,
        output_model_type=DataModelType.PydanticV2BaseModel,
    )
    print(f"✅ Generated models at {output_path}")


def migrate_memory(source_path: str, model_path: str = "models/e5-small.onnx"):
    df = openai.read_source(source_path)
    embedder = OnnxEmbedder(model_path)
    df["embedding"] = embedder.encode(df["text"].tolist()).tolist()
    duckdb_store.write_destination(df)
    return df
