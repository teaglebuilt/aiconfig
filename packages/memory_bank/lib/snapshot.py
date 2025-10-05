import os
import datetime as dt
import pyarrow as pa
import pyarrow.parquet as pq
import lancedb

GM_DB = os.getenv("GM_DB", os.path.expanduser("~/.global-memory/lancedb"))
OUT = os.path.expanduser("~/.global-memory/export")


def snapshot():
    db = lancedb.connect(GM_DB)
    tbl = db.open_table("memory")
    rows = tbl.query().limit(10_000_000).to_list()  # pull all; filter if needed
    pa_tbl = pa.Table.from_pylist(rows)
    ts = dt.datetime.utcnow().strftime("%Y-%m-%d")
    outdir = os.path.join(OUT, ts)
    os.makedirs(outdir, exist_ok=True)
    pq.write_table(pa_tbl, os.path.join(outdir, "memory.parquet"))
    return outdir


if __name__ == "__main__":
    print(snapshot())
