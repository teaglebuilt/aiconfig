# AIConfig Architecture

## Overview

AIConfig is a portable, centralized configuration system that enables seamless context sharing across AI coding clients. It provides a single source of truth for preferences, memory, skills, and workflows.

```
┌───────────────────────────────────────────────────────────────────────┐
│                            AIConfig                                   │
│  ~/aiconfig (symlinked from repository)                               │
├───────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────┐    ┌─────────────────────────────┐   │
│  │       CLIENT CONFIGS        │    │      SHARED KNOWLEDGE       │   │
│  │                             │    │                             │   │
│  │  ┌─────────┐  ┌─────────┐   │    │  ┌─────────────────────┐    │   │
│  │  │.claude/ │  │.cursor/ │   │    │  │     context/        │    │   │
│  │  │ agents  │  │ agents  │   │    │  │  coding-standards/  │    │   │
│  │  │ skills  │  │ rules   │   │    │  │  workflows/         │    │   │
│  │  │commands │  │         │   │    │  │  prompts/           │    │   │
│  │  │ hooks   │  │         │   │    │  │  knowledge/         │    │   │
│  │  └─────────┘  └─────────┘   │    │  │  knowledge/         │    │   │
│  └─────────────────────────────┘    │  └─────────────────────┘    │   │
│                                     │  (static, human-authored)   │   │
│  ┌─────────────────────────────┐    └─────────────────────────────┘   │
│  │      PERSISTENT DATA        │                                      │
│  │                             │    ┌─────────────────────────────┐   │
│  │  ┌─────────────────────┐    │    │      INTEGRATION            │   │
│  │  │     memory/         │    │    │                             │   │
│  │  │  global/            │    │    │  ┌─────────────────────┐    │   │
│  │  │  projects/{name}/   │    │    │  │  mcp.yaml (source)  │    │   │
│  │  │  vectors/lancedb/   │    │    │  │  packages/config/   │    │   │
│  │  └─────────────────────┘    │    │  │  (generates JSON)   │    │   │
│  │  (dynamic, AI-updated)      │    │  └─────────────────────┘    │   │
│  └─────────────────────────────┘    └─────────────────────────────┘   │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
                    │                           │
        ┌───────────┴───────────┐   ┌───────────┴───────────┐
        ▼                       ▼   ▼                       ▼
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│  Claude Code  │       │    Cursor     │       │  Other Tools  │
│  ~/.claude    │       │   ~/.cursor   │       │  (via MCP)    │
└───────────────┘       └───────────────┘       └───────────────┘
```

---

## Directory Structure

```
aiconfig/
├── .claude/                    # Claude Code client config
│   ├── agents/                 # Custom agent definitions
│   ├── commands/               # Slash commands (legacy, still supported)
│   ├── hooks/                  # Event hooks
│   └── skills/                 # Skills (primary extension mechanism)
│
├── .cursor/                    # Cursor client config
│   ├── agents/                 # Custom agent definitions
│   └── rules/                  # Context rules (.mdc files)
│
├── context/                    # Shared coding context
│   ├── coding-standards/       # TypeScript, testing standards
│   ├── knowledge/              # Best practices, patterns
│   ├── prompts/                # Code review, debugging prompts
│   └── workflows/              # Git, feature development flows
│
├── memory/                     # Persistent storage
│   ├── global/                 # Cross-project preferences
│   ├── projects/{name}/        # Per-project context
│   ├── schemas/                # JSON Schema validation
│   └── vectors/lancedb/        # Semantic search embeddings
│
├── mcp-config/                 # MCP server configurations
│   ├── claude-code.json        # Claude Code MCP settings
│   └── cursor.json             # Cursor MCP settings
│
├── scripts/                    # Installation and utilities
│   └── install.sh              # Setup script
│
├── templates/                  # Document templates
│   ├── feature-template.md
│   └── task-template.md
│
└── docs/                       # Documentation
    ├── architecture.md         # This file
    ├── prd.md                  # Product requirements
    ├── features/               # Feature documentation
    └── stories/                # Implementation stories
```

---

## Context vs Memory

AIConfig separates **static knowledge** from **dynamic data**:

| Aspect | `context/` | `memory/` |
|--------|------------|-----------|
| **Purpose** | Coding standards, workflows, prompts | Session history, project state, decisions |
| **Nature** | Static, human-authored | Dynamic, AI-updated |
| **Changes** | Rarely (versioned with repo) | Frequently (per session) |
| **Scope** | Universal guidelines | Project-specific data |

### context/ - "How we work"

Reference documents that guide AI behavior:

```
context/
├── coding-standards/      # TypeScript, testing conventions
│   ├── typescript.md
│   └── testing.md
├── workflows/             # Development processes
│   ├── git-conventions.md
│   └── feature-development.md
├── prompts/               # Reusable prompt templates
│   ├── code-review.md
│   └── debugging.md
└── knowledge/             # Best practices
    └── ai-coding-best-practices.md
```

### memory/ - "What we've done"

Persistent data that evolves over time:

```
memory/
├── global/                # Cross-project preferences
├── projects/{name}/       # Per-project history
│   ├── context.json       # Current project state
│   ├── sessions.json      # Session logs
│   └── decisions.json     # ADRs
└── vectors/               # Semantic search index
```

---

## Client Integration

### Symlink Architecture

The install script creates symlinks from user home directories to the aiconfig repository:

```
~/.claude    →  aiconfig/.claude/
~/.cursor    →  aiconfig/.cursor/
~/aiconfig   →  aiconfig/
```

This enables:
- **Single source of truth**: All config lives in one versioned repository
- **Instant updates**: Changes propagate to all clients immediately
- **Portable setup**: Clone repo + run install = fully configured

### Claude Code

**Config location**: `~/.claude/` (symlinked)

| Component | Path | Purpose |
|-----------|------|---------|
| Agents | `.claude/agents/*.md` | Custom agent definitions |
| Skills | `.claude/skills/*/SKILL.md` | Primary extension mechanism — invokable via `/name`, auto-discovered by Claude and Cursor |
| Commands | `.claude/commands/*.md` | Legacy slash commands (merged into skills, still supported) |
| Hooks | `.claude/settings.json` | Event-driven automation (JSON config, not markdown) |

**MCP Integration**: `~/.config/claude-code/settings.json`

### Cursor

**Config location**: `~/.cursor/` (symlinked)

| Component | Path | Purpose |
|-----------|------|---------|
| Agents | `.cursor/agents/*.md` | Custom agent definitions |
| Rules | `.cursor/rules/*.mdc` | Context rules for the AI |

**MCP Integration**: `~/.cursor/mcp.json`

**Cross-Compatibility**: Cursor auto-detects Claude Code resources:
- Skills from `.claude/skills/` (enable "Third-party skills" in settings)
- Hooks from `.claude/settings.json` (auto-maps hook names)

This means skills and hooks only need to be defined once in `.claude/`.

### Hook Compatibility

Cursor natively reads Claude Code hooks. Define hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [{"matcher": "Shell", "command": "..."}],
    "sessionEnd": [{"command": "..."}]
  }
}
```

Cursor automatically maps hook names:

| Claude Code | Cursor |
|-------------|--------|
| `PreToolUse` | `preToolUse` |
| `PostToolUse` | `postToolUse` |
| `sessionStart/End` | `sessionStart/End` |

See [Hooks Documentation](./features/hooks.md) for details.


## MCP Configuration

### Overview

Both clients connect to shared MCP servers:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ basic-memory│     │   lancedb   │     │ filesystem  │
│  (notes)    │     │  (vectors)  │     │   (files)   │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
              ┌────────────┴────────────┐
              │                         │
       ┌──────▼──────┐          ┌───────▼──────┐
       │ Claude Code │          │    Cursor    │
       └─────────────┘          └──────────────┘
```

### MCP Servers

| Server | Purpose | Command |
|--------|---------|---------|
| `basic-memory` | Persistent markdown notes, knowledge graph | `uvx basic-memory mcp` |
| `lancedb` | Vector embeddings for semantic search | `uvx lancedb-mcp` |
| `filesystem` | Direct file access to aiconfig | `npx @anthropic/mcp-server-filesystem` |

### Configuration Files

**Claude Code** (`mcp-config/claude-code.json`):
```json
{
  "mcpServers": {
    "basic-memory": {
      "command": "uvx",
      "args": ["basic-memory", "mcp"]
    },
    "lancedb": {
      "command": "uvx",
      "args": ["lancedb-mcp"],
      "env": {
        "LANCEDB_URI": "${AICONFIG_PATH:-$HOME/aiconfig}/memory/vectors/lancedb",
        "LANCEDB_TABLE": "aiconfig_embeddings"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem"],
      "env": {
        "ALLOWED_PATHS": "${AICONFIG_PATH:-$HOME/aiconfig}"
      }
    }
  }
}
```

**Cursor** (`mcp-config/cursor.json`):
```json
{
  "mcpServers": {
    "basic-memory": {
      "command": "uvx",
      "args": ["basic-memory", "mcp"]
    },
    "lancedb": {
      "command": "uvx",
      "args": ["lancedb-mcp"],
      "env": {
        "LANCEDB_URI": "~/aiconfig/memory/vectors/lancedb",
        "LANCEDB_TABLE": "aiconfig_embeddings"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "~/aiconfig"]
    }
  }
}
```

---

## Skills & Agents

### Skills (Primary Extension Mechanism)

Skills are defined in `SKILL.md` format and auto-discovered by both Claude Code and Cursor from `.claude/skills/`. Do not duplicate into `.cursor/skills/`.

| Skill | Purpose | Side Effects |
|-------|---------|--------------|
| `/init-memory` | Initialize project memory | Writes files |
| `/log-session` | Record session to memory | Writes files |
| `/recall` | Search past context | Read-only |
| `/generate-prd` | Generate a PRD | Writes files |
| `/architect` | Architecture analysis | Read-only |
| `/claude-code` | Claude Code architecture — hooks, observability, agent workflows | Read-only |

**Skill structure**:
```
.claude/skills/
├── init-memory/SKILL.md
├── log-session/SKILL.md
├── recall/SKILL.md
├── generate-prd/SKILL.md
├── architect/
│   ├── SKILL.md
│   ├── references/
│   └── templates/
└── claude-code/
    ├── SKILL.md
    └── references/
```

### Commands (Legacy, Still Supported)

Simple single-file slash commands in `.claude/commands/*.md`. Merged into the skills system — both create `/slash-commands` and support the same frontmatter. Use skills for new development; commands remain for lightweight prompts that don't need supporting files.

See [Commands vs Skills](./features/commands.md) for detailed guidance.

### Custom Agents

| Agent | Purpose | Paired Skill |
|-------|---------|-------------|
| `architect-agent` | Architecture advisor, pattern evaluation | `/architect` |
| `developer-agent` | Implementation specialist, coding standards | `/developer` |
| `claude-code-agent` | Claude Code hooks, observability, agent workflows | `/claude-code` |
| `memory-manager` | Session and decision management | — |

---

## Data Flow

### Session Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                    Session Start                            │
├─────────────────────────────────────────────────────────────┤
│  1. Client loads from ~/.claude or ~/.cursor                │
│  2. MCP servers connect to shared memory                    │
│  3. /recall retrieves relevant project context              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Active Session                           │
├─────────────────────────────────────────────────────────────┤
│  - Context from memory/projects/{name}/context.json         │
│  - Rules from context/ directory                            │
│  - Previous session history available                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Session End                              │
├─────────────────────────────────────────────────────────────┤
│  1. /log-session records work to sessions.json              │
│  2. Decisions captured in decisions.json                    │
│  3. Embeddings updated in LanceDB (if enabled)              │
└─────────────────────────────────────────────────────────────┘
```

### Cross-Client Handoff

```
Claude Code                              Cursor
    │                                       │
    │  /log-session                         │
    │  ────────────►  memory/projects/      │
    │                      │                │
    │                      │   /recall      │
    │                      ◄────────────────│
    │                                       │
    ▼                                       ▼
Context persisted                   Context restored
```

---

## Installation

### Quick Start

```bash
git clone <repo> ~/projects/aiconfig
cd ~/projects/aiconfig
make install
```

### What Install Does

1. **Creates symlinks**:
   - `~/aiconfig` → repository
   - `~/.claude` → repository/.claude
   - `~/.cursor` → repository/.cursor

2. **Configures MCP**:
   - Claude Code: `~/.config/claude-code/settings.json`
   - Cursor: `~/.cursor/mcp.json`

3. **Sets environment**:
   - Adds `AICONFIG_PATH` to shell profile

### Dependencies

```bash
# MCP servers
pip install basic-memory lancedb lancedb-mcp
```

---

## Feature Documentation

- [Agents](./features/agents.md)
- [Hooks](./features/hooks.md)
- [Skills](./features/skills.md)
- [Commands](./features/commands.md)

---

## Related Documents

- [PRD](./prd.md) - Product requirements and use cases
- [Stories](./stories/) - Implementation stories
