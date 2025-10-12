CREATE VIEW journal AS
SELECT * FROM read_json_auto('~/.global-memory/journal.jsonl');

-- Volume by op per day
SELECT date_trunc('day', ts)::DATE AS day, op, COUNT(*) AS n
FROM journal
GROUP BY 1,2
ORDER BY 1,2;