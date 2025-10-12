import duckdb


def write_destination(df, path="memory.duckdb"):
    con = duckdb.connect(path)
    con.execute("INSTALL vss; LOAD vss;")
    con.register("staging", df)
    con.execute("""
        CREATE TABLE IF NOT EXISTS memory AS SELECT * FROM staging;
    """)
    con.execute("""
        CREATE INDEX IF NOT EXISTS memory_idx ON memory (embedding) USING HNSW;
    """)
    con.close()
    print(f"✅ Wrote {len(df)} rows to {path}")
