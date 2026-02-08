# File Locking Quick Reference

## Common Commands

### Write Operations

```bash
# Safe write with locking (recommended)
echo '{"data": "value"}' | ./scripts/atomic-write.sh /path/to/file.json

# Safe update with jq
./scripts/memory-update.sh /path/to/file.json '.counter += 1'

# Safe update with backup
./scripts/memory-update.sh /path/to/file.json '.data = "new"' --backup
```

### Read Operations

```bash
# Safe read
./scripts/memory-read.sh /path/to/file.json

# Raw output (for scripting)
./scripts/memory-read.sh /path/to/file.json --raw
```

### Lock Management

```bash
# Show current locks
./scripts/file-lock.sh show

# Clean stale locks
./scripts/file-lock.sh cleanup

# Manual lock/unlock
LOCK_ID=$(./scripts/file-lock.sh acquire /path/to/file.json)
# ... do work ...
./scripts/file-lock.sh release "$LOCK_ID"

# Execute with lock
./scripts/file-lock.sh with /path/to/file.json -- command args
```

## Environment Variables

```bash
LOCK_TIMEOUT=30      # Max seconds to wait for lock (default: 30)
LOCK_RETRY=0.1       # Retry interval in seconds (default: 0.1)
LOCK_DEBUG=1         # Enable debug output (0/1)
AICONFIG_PATH=~/aiconfig  # AIConfig directory
```

## Memory Skill Integration

```bash
# /init-memory
echo "$content" | ~/aiconfig/scripts/atomic-write.sh \
  ~/aiconfig/memory/projects/${project}/context.json

# /log-session
~/aiconfig/scripts/memory-update.sh \
  ~/aiconfig/memory/projects/${project}/sessions.json \
  ".sessions += [${session}]" --backup

# /recall
~/aiconfig/scripts/memory-read.sh \
  ~/aiconfig/memory/projects/${project}/sessions.json
```

## Troubleshooting

```bash
# Lock timeout error?
./scripts/file-lock.sh show          # Check active locks
./scripts/file-lock.sh cleanup       # Clean stale locks
LOCK_TIMEOUT=60 command              # Increase timeout

# Debug lock issues
LOCK_DEBUG=1 ./scripts/file-lock.sh with /path/to/file.json -- cat /path/to/file.json
```

## Test

```bash
# Run test suite
./scripts/test-file-locking.sh

# Quick test
echo '{"test": 1}' | ./scripts/atomic-write.sh /tmp/test.json
./scripts/memory-update.sh /tmp/test.json '.test += 1'
cat /tmp/test.json  # Should show {"test": 2}
```

## Files

| Script | Purpose |
|--------|---------|
| `file-lock.sh` | Core locking |
| `atomic-write.sh` | Safe writes |
| `memory-update.sh` | Safe updates |
| `memory-read.sh` | Safe reads |

## Documentation

- Technical: [docs/features/file-locking.md](./features/file-locking.md)
- Examples: [docs/examples/concurrent-access.md](./examples/concurrent-access.md)
- Story: [docs/stories/context-management-01.story.md](./stories/context-management-01.story.md)
