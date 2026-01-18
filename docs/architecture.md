
1. [Overview](#overview)
2. [Configuration](#configuration)
3. [Context Management](#context)
4. [Memory Management](#memory)
  1. [Global](#global-memory)
  2. [Project](#project-memory)

### Configuration

### MCP Integration

The memory system integrates with AI clients via MCP servers:

```
mcp-config/
  claude-code.json
  cursor.json
```

```json
{
  "mcpServers": {
    "basic-memory": {
      "command": "uvx",
      "args": ["basic-memory", "mcp"],
      "description": "Persistent memory with markdown notes"
    }
  }
}
```

### Memory

Both Claude Code and Cursor can access the same memory:

```
                    ┌─────────────────┐
                    │  aiconfig/      │
                    │  memory/        │
                    └────────┬────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
    ┌───────▼───────┐ ┌──────▼──────┐ ┌───────▼───────┐
    │  Claude Code  │ │   Cursor    │ │  Other Tools  │
    │  (MCP Server) │ │ (File Read) │ │  (API/Files)  │
    └───────────────┘ └─────────────┘ └───────────────┘
```

#### Global Memory

Path: `memory/global/`

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

#### Project Memory

Path: `memory/projects/{name}/`

Per-project context that persists across sessions:

- **context.json**: Tech stack, architecture, current focus
- **sessions.json**: History of AI coding sessions
- **decisions.json**: Architectural Decision Records (ADRs)


#### Memory Retreival

LanceDB provides vector-based retrieval with no server required:

**Storage Location**: `memory/vectors/lancedb/`

```json
{
  "lancedb": {
    "command": "uvx",
    "args": ["lancedb-mcp"],
    "env": {
      "LANCEDB_URI": "$HOME/aiconfig/memory/vectors/lancedb",
      "LANCEDB_TABLE": "aiconfig_embeddings"
    }
  }
}
```

**Benefits**

- **Embedded**: No server to manage, data stored as files
- **Portable**: Vector DB travels with your aiconfig
- **Fast**: Native vector search with filtering
- **Compatible**: Works alongside basic-memory

**Use Cases**:
- "Find similar problems I've solved before"
- "What patterns have I used for authentication?"
- "Retrieve relevant context for React performance"
