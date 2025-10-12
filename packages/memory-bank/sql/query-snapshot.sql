-- duckdb
INSTALL httpfs; LOAD httpfs; -- if reading from S3/http
PRAGMA threads=8;

-- Local Parquet snapshot
CREATE VIEW mem AS
SELECT * FROM read_parquet('~/.global-memory/export/2025-10-05/memory.parquet');

-- Top tags
SELECT tag, COUNT(*) AS cnt
FROM mem, UNNEST(tags) AS tag
GROUP BY 1
ORDER BY cnt DESC
LIMIT 20;

-- Pinned rate by project
SELECT project,
       AVG(CASE WHEN pinned THEN 1 ELSE 0 END) AS pinned_rate,
       COUNT(*) AS n
FROM mem
GROUP BY 1
ORDER BY n DESC
LIMIT 20;

-- Stale items (>90 days), no TTL
SELECT id, project, repo, substr(content, 1, 120) AS preview, updated_at
FROM mem
WHERE updated_at < now() - INTERVAL 90 DAY
  AND (ttl_sec IS NULL OR ttl_sec = 0)
ORDER BY updated_at ASC
LIMIT 50;
