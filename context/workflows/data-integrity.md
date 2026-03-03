# Data Integrity Agent

When working with memory files in `~/aiconfig/memory/`, follow these practices to ensure data integrity across concurrent Claude Code and Cursor sessions.

## Memory File Locations

```
~/aiconfig/memory/
├── global/preferences.json      # Cross-project preferences
├── projects/{name}/
│   ├── context.json             # Project state
│   ├── sessions.json            # Session history
│   └── decisions.json           # ADRs
└── schemas/                     # JSON Schema validation
```

## Writing to Memory Files

**Always use atomic writes with locking for shared files:**

```bash
# Safe write with locking and backup
echo '{"data": "..."}' | ~/aiconfig/scripts/atomic-write.sh /path/to/file.json --lock --backup --client claude-code
```

**Why:**
- `--lock` prevents Claude Code and Cursor from writing simultaneously
- `--backup` creates `.bak` file before overwriting
- `--client claude-code` identifies the lock holder

## Reading Memory Files

Before modifying, read the current version vector:

```bash
~/aiconfig/scripts/version-vector.sh read /path/to/file.json
```

Store this locally to detect if another client modified the file while you were working.

## Conflict Detection

Before writing, check if the file changed:

```bash
~/aiconfig/scripts/version-vector.sh check /path/to/file.json --client claude-code --expected '{"claude-code":1,"cursor":2}'
```

If conflict detected, use merge strategies:

```bash
# Sessions can be safely merged (append)
~/aiconfig/scripts/merge-memory.sh sessions ours.json --theirs theirs.json

# Decisions need review (may conflict)
~/aiconfig/scripts/merge-memory.sh decisions ours.json --theirs theirs.json

# Context uses smart merge
~/aiconfig/scripts/merge-memory.sh context ours.json --theirs theirs.json
```

## After Writing

Increment version vector:

```bash
~/aiconfig/scripts/version-vector.sh increment /path/to/file.json --client claude-code
```

## Quick Reference

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `atomic-write.sh` | Safe file writes | Every memory file write |
| `file-lock.sh` | Prevent concurrent writes | Via `--lock` flag |
| `version-vector.sh` | Track modifications | Before/after writes |
| `merge-memory.sh` | Resolve conflicts | When versions diverge |

## Skills That Write to Memory

These skills should use data integrity scripts:
- `/init-memory` - Creates project memory files
- `/log-session` - Appends to sessions.json
- Any skill that modifies memory files

## Example: Safe Session Logging

```bash
# 1. Read current state
current_version=$(~/aiconfig/scripts/version-vector.sh read ~/aiconfig/memory/projects/myapp/sessions.json)

# 2. Prepare new content (add session to existing)
new_content='...'

# 3. Write atomically with lock
echo "$new_content" | ~/aiconfig/scripts/atomic-write.sh \
  ~/aiconfig/memory/projects/myapp/sessions.json \
  --lock --backup --client claude-code

# 4. Increment version
~/aiconfig/scripts/version-vector.sh increment \
  ~/aiconfig/memory/projects/myapp/sessions.json \
  --client claude-code
```
