import typer

from memory_migrate.core.commands import export_memory, migrate_memory

app = typer.Typer(help="Migrate AI memory using DuckDB + ONNX.")


@app.command()
def export(
    adapter: str = typer.Argument(..., help="Adapter to export from (e.g., 'openai')"),
    output: str = typer.Option("export.json", help="Output file path"),
    api_key: str = typer.Option(None, "--api-key", help="API key for the adapter"),
):
    typer.echo(f"🚀 Exporting conversations from {adapter}")
    export_memory(adapter, output, api_key)
    typer.echo(f"✅ Exported to {output}")


@app.command()
def migrate(
    source: str = typer.Argument(..., help="Path to OpenAI export JSON"),
    model: str = typer.Option("models/e5-small.onnx", help="Path to ONNX model"),
):
    typer.echo(f"🚀 Migrating memory from {source}")
    df = migrate_memory(source, model)
    typer.echo(f"✅ Imported {len(df)} records")
