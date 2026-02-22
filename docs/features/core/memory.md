## Memory System

### Memory Hierarchy

```
memory/
├── global/                     # User-wide preferences
│   └── preferences.json        # Coding style, patterns
│
├── projects/
│   └── {project-name}/
│       ├── context.json        # Tech stack, architecture
│       ├── sessions.json       # Session history
│       └── decisions.json      # ADRs (Architectural Decision Records)
│
└── vectors/
    └── lancedb/                # Semantic search index
```

### Global Memory

**Path**: `memory/global/`

Cross-project preferences and learned patterns:

```json
{
  "coding_preferences": {
    "patterns": { "preferred": ["functional", "immutable"] },
    "testing": { "approach": "TDD when appropriate" }
  },
  "learned_preferences": [
    { "context": "error_handling", "preference": "Result types over exceptions" }
  ]
}
```

### Project Memory

**Path**: `memory/projects/{name}/`

Per-project context that persists across sessions:

| File | Purpose | Schema |
|------|---------|--------|
| `context.json` | Tech stack, architecture, current focus | Project metadata |
| `sessions.json` | History of AI coding sessions | Session logs |
| `decisions.json` | Architectural Decision Records | ADR format |

**context.json** example:
```json
{
  "project": "my-app",
  "tech_stack": ["TypeScript", "React", "Node.js"],
  "architecture": "monorepo with pnpm workspaces",
  "current_focus": "implementing authentication",
  "conventions": {
    "testing": "vitest with react-testing-library",
    "styling": "tailwindcss"
  }
}
```

**sessions.json** example:
```json
{
  "sessions": [
    {
      "id": "session-20260123-001",
      "date": "2026-01-23",
      "client": "claude-code",
      "summary": "Implemented user authentication flow",
      "files_changed": ["src/auth/*", "src/api/login.ts"],
      "decisions": ["Using JWT with httpOnly cookies"],
      "follow_ups": ["Add refresh token rotation"]
    }
  ]
}
```

### Schema Validation

**Path**: `memory/schemas/`

JSON Schema definitions ensure data integrity:

| Schema | Validates | Key Requirements |
|--------|-----------|------------------|
| `preferences.schema.json` | Global preferences | version, coding_preferences |
| `context.schema.json` | Project context | project, created |
| `sessions.schema.json` | Session history | project, sessions array with id/date/summary |
| `decisions.schema.json` | ADRs | project, decisions array with id/date/title/decision/status |

Memory files reference their schema:
```json
{
  "$schema": "../schemas/sessions.schema.json",
  "project": "my-app",
  "sessions": []
}
```

### Version Vectors

**Script**: `scripts/version-vector.sh`

Version vectors track per-client modifications for conflict detection:

```bash
# Read current version vector
~/aiconfig/scripts/version-vector.sh read /path/to/file.json
# Output: {"claude-code": 3, "cursor": 2}

# Increment version after modification
~/aiconfig/scripts/version-vector.sh increment /path/to/file.json --client claude-code

# Check for conflicts before writing
~/aiconfig/scripts/version-vector.sh check /path/to/file.json --client cursor --expected '{"claude-code":2,"cursor":1}'
# Output: conflict: claude-code (if claude-code modified since last read)
```

Memory files store version in `_version` field:
```json
{
  "_version": {
    "claude-code": 3,
    "cursor": 2
  },
  "project": "my-app",
  "sessions": []
}
```

**Conflict detection workflow**:
1. Client reads file and stores version vector locally
2. Client makes modifications
3. Before writing, client checks if versions changed
4. If conflict detected, client can merge or prompt user

### Merge Strategies

**Script**: `scripts/merge-memory.sh`

Different file types use different merge strategies:

| File Type | Strategy | Behavior |
|-----------|----------|----------|
| `sessions.json` | Append | Combine all sessions, deduplicate by ID |
| `decisions.json` | Manual | Flag conflicting ADRs with `_conflict: true` |
| `context.json` | Smart | Union arrays, flag scalar conflicts |

```bash
# Merge sessions (safe - always appendable)
~/aiconfig/scripts/merge-memory.sh sessions ours.json --theirs theirs.json

# Merge decisions (may have conflicts)
~/aiconfig/scripts/merge-memory.sh decisions ours.json --theirs theirs.json

# Merge context (smart merge)
~/aiconfig/scripts/merge-memory.sh context ours.json --theirs theirs.json
```

Conflicts are marked in the output:
```json
{
  "current_focus": {
    "_value": "auth feature",
    "_conflict": true,
    "_their_value": "payment feature"
  }
}
```

### File Locking

**Script**: `scripts/file-lock.sh`

Advisory locking prevents concurrent writes from multiple clients:

```bash
# Acquire lock (waits up to 30s, identifies as claude-code)
~/aiconfig/scripts/file-lock.sh acquire /path/to/file.json --client claude-code

# Release lock when done
~/aiconfig/scripts/file-lock.sh release /path/to/file.json

# Check lock status
~/aiconfig/scripts/file-lock.sh status /path/to/file.json

# Clean up stale locks (older than 5 minutes)
~/aiconfig/scripts/file-lock.sh cleanup
```

Lock file format (`file.json.lock`):
```json
{
  "target": "/path/to/file.json",
  "client": "claude-code",
  "acquired_at": "2026-01-23T10:00:00Z",
  "pid": 12345,
  "hostname": "macbook"
}
```

### Atomic Writes

**Script**: `scripts/atomic-write.sh`

Prevents file corruption during writes:

```bash
# Write JSON atomically with validation, backup, and locking
echo '{"data": "value"}' | ~/aiconfig/scripts/atomic-write.sh /path/to/file.json --backup --lock --client claude-code
```

Options:
- `--backup` - Create `.bak` backup before overwriting
- `--lock` - Acquire file lock before writing (recommended for shared files)
- `--client NAME` - Identifier for lock holder

How it works:
1. Acquires file lock (if `--lock` flag)
2. Writes content to temp file in same directory
3. Validates JSON (auto-detected for `.json` files)
4. Creates backup if `--backup` flag is set
5. Atomically renames temp file to target (POSIX `mv` is atomic on same filesystem)
6. Releases lock

### Vector Memory (LanceDB)

**Path**: `memory/vectors/lancedb/`

Embedded vector database for semantic search:

- **No server required**: Data stored as files
- **Portable**: Travels with your aiconfig
- **Fast**: Native vector search with filtering

**Use cases**:
- "Find similar problems I've solved before"
- "What patterns have I used for authentication?"
- "Retrieve relevant context for React performance"
