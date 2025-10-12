from fastapi import FastAPI, UploadFile

from memory_migrate.core.migrate import migrate_memory

app = FastAPI()


@app.post("/migrate")
async def migrate(file: UploadFile):
    path = f"/tmp/{file.filename}"
    with open(path, "wb") as f:
        f.write(await file.read())
    df = migrate_memory(path)
    return {"rows": len(df)}
