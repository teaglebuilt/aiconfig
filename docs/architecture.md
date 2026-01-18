
1. [Overview](#overview)
2. [Configuration](#configuration)
3. [Context Management](#context)
4. [Memory Management](#memory)
  1. [Global](#global-memory)
  2. [Project](#project-memory)
5. [Agents]()
6. [Commands]()
7. [Skills](#skills)

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

### Skills

Skills are reusable prompts that extend agent capabilities.

#### Available Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| `/init-memory` | "init memory", "setup memory" | Initialize project memory structure |
| `/log-session` | "log session", "end session" | Record session to project memory |
| `/recall` | "recall", "remember", "what did we decide" | Search memory for past context |
| `/generate-prd` | "create a prd", "plan this feature" | Generate Product Requirements Document |
| `/generate-prd-to-json` | "convert this prd", "ralph json" | Convert PRD to Ralph agent format |

#### Skill Discovery

Skills are auto-discovered from these locations:

| Location | Scope | Client |
|----------|-------|--------|
| `.cursor/skills/` | Project | Cursor |
| `.claude/skills/` | Project | Claude Code, Cursor |
| `~/.cursor/skills/` | Global | Cursor |
| `~/.claude/skills/` | Global | Claude Code, Cursor |

Both clients use the same `SKILL.md` format - skills are portable.

#### Skill Structure

```
.claude/skills/              # Shared (both clients)
├── init-memory/SKILL.md
├── log-session/SKILL.md
├── recall/SKILL.md
├── generate-prd/SKILL.md
└── generate-prd-to-json/SKILL.md

.cursor/skills/              # Cursor-specific (optional)
├── init-memory/SKILL.md
├── log-session/SKILL.md
└── recall/SKILL.md
```

#### Memory Skills Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  /init-memory   │────▶│   (coding...)   │────▶│  /log-session   │
│  Start project  │     │                 │     │  End of session │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                         │
                                                         ▼
┌─────────────────┐     ┌─────────────────────────────────────────┐
│    /recall      │◀────│  memory/projects/{name}/sessions.json   │
│  Next session   │     │  memory/projects/{name}/decisions.json  │
└─────────────────┘     └─────────────────────────────────────────┘
```

#### Skill Format

```markdown
---
name: skill-name
description: "Brief description. Triggers on: keyword1, keyword2."
---

# Skill Title

What this skill does.

## The Job
1. Step one
2. Step two

## Output
What the skill produces.
```

#### Sharing Skills Across Clients

Skills use an open standard - the same `SKILL.md` format works in both Claude Code and Cursor.

**Project-level**: Place in `.claude/skills/` (both clients discover it)

**Global-level**: The install script symlinks to `$HOME`:
- `~/.claude/skills/` → Available to Claude Code and Cursor
- `~/.cursor/skills/` → Available to Cursor

**Invoking skills**: Type `/` in chat to see available skills, or use trigger phrases.

#### References

- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Cursor Skills](https://cursor.com/docs/context/skills)
