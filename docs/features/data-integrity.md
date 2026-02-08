# Data Integrity

This guide explains how AIConfig ensures safe concurrent access to memory files from multiple AI clients.

## Overview

When using both Claude Code and Cursor on the same project, both clients may read/write to shared memory files. The data integrity system prevents corruption through:

1. **Atomic writes** - Files are never partially written
2. **File locking** - Only one client writes at a time
3. **Version vectors** - Detect when another client modified a file
4. **Merge strategies** - Resolve conflicts intelligently

## Who Uses What

| Actor | Action | Tool |
|-------|--------|------|
| You (user) | Invoke skills | `/log-session`, `/init-memory`, `/recall` |
| AI client | Writes safely | Scripts called by skills |
| Scripts | Handle mechanics | `atomic-write.sh`, `file-lock.sh`, etc. |

**You don't need to run the scripts manually.** The AI clients use them when executing skills.

## Workflow

### Starting a Session

1. Open your project in Claude Code or Cursor
2. The AI can read memory from `~/aiconfig/memory/projects/{project}/`
3. Use `/recall` to search past context if needed

### During a Session

Work normally. The AI tracks:
- Files you modify
- Decisions you make
- Problems you solve

### Ending a Session

Use `/log-session` to save context:

```
/log-session
```

The skill will:
1. Summarize what was accomplished
2. Record files changed
3. Note decisions and follow-ups
4. **Write safely using atomic writes with locking**

### Switching Clients

When switching from Claude Code to Cursor (or vice versa):

1. Run `/log-session` in the current client
2. Switch to the other client
3. Use `/recall` to load context
4. Continue working

The data integrity scripts ensure the handoff is safe.

## Scripts Reference

These scripts are in `~/aiconfig/scripts/`:

### atomic-write.sh

Writes files safely with optional locking.

```bash
# Basic usage (AI clients call this)
echo '{"data": "value"}' | ./atomic-write.sh /path/to/file.json

# With locking (recommended for shared files)
echo '{"data": "value"}' | ./atomic-write.sh /path/to/file.json --lock --client claude-code

# With backup
echo '{"data": "value"}' | ./atomic-write.sh /path/to/file.json --backup
```

### file-lock.sh

Manages file locks for concurrent access.

```bash
# Check if a file is locked
./file-lock.sh status /path/to/file.json

# Clean up stale locks (if a client crashed)
./file-lock.sh cleanup
```

### version-vector.sh

Tracks which client modified a file and when.

```bash
# See current versions
./version-vector.sh read /path/to/file.json
# Output: {"claude-code": 3, "cursor": 2}

# View summary
./version-vector.sh summary /path/to/file.json
```

### merge-memory.sh

Resolves conflicts when both clients modified a file.

```bash
# Merge sessions (always safe - appends)
./merge-memory.sh sessions file1.json --theirs file2.json

# Merge decisions (flags conflicts for review)
./merge-memory.sh decisions file1.json --theirs file2.json

# Merge context (smart merge)
./merge-memory.sh context file1.json --theirs file2.json
```

## Troubleshooting

### "Failed to acquire lock"

Another client is writing to the file. Wait a moment and retry, or check if a client crashed:

```bash
# Check lock status
~/aiconfig/scripts/file-lock.sh status /path/to/file.json

# If stale (client crashed), clean up
~/aiconfig/scripts/file-lock.sh cleanup
```

### Conflict Detected

If you see `_conflict: true` in a file, both clients modified the same field:

```json
{
  "current_focus": {
    "_value": "auth feature",
    "_conflict": true,
    "_their_value": "payment feature"
  }
}
```

Resolve manually by choosing the correct value and removing the conflict markers.

### Corrupted File

If a file is corrupted, restore from backup:

```bash
cp /path/to/file.json.bak /path/to/file.json
```

Backups are created when using `--backup` flag.

## Best Practices

1. **Always use `/log-session`** before switching clients
2. **Use `/recall`** when starting work to load context
3. **Don't edit memory files manually** - let the AI handle it
4. **Run `file-lock.sh cleanup`** if a client crashes mid-write
