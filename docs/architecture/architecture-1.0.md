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
│  │  │ skills  │  │ skills  │   │    │  │  workflows/         │    │   │
│  │  │ hooks   │  │ rules   │   │    │  │  prompts/           │    │   │
│  │  └─────────┘  └─────────┘   │    │  │  knowledge/         │    │   │
│  └─────────────────────────────┘    │  └─────────────────────┘    │   │
│                                     │  (static, human-authored)   │   │
│  ┌─────────────────────────────┐    └─────────────────────────────┘   │
│  │      PERSISTENT DATA        │                                      │
│  │                             │    ┌─────────────────────────────┐   │
│  │  ┌─────────────────────┐    │    │      INTEGRATION            │   │
│  │  │     memory/         │    │    │                             │   │
│  │  │  global/            │    │    │  ┌─────────────────────┐    │   │
│  │  │  projects/{name}/   │    │    │  │    mcp-config/      │    │   │
│  │  │  vectors/lancedb/   │    │    │  │  claude-code.json   │    │   │
│  │  └─────────────────────┘    │    │  │  cursor.json        │    │   │
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
│   ├── commands/               # Slash commands
│   ├── hooks/                  # Event hooks
│   └── skills/                 # Portable skills
│
├── .cursor/                    # Cursor client config
│   ├── agents/                 # Custom agent definitions
│   ├── rules/                  # Context rules (.mdc files)
│   └── skills/                 # Portable skills
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
| Skills | `.claude/skills/*/SKILL.md` | Invokable skills (/init-memory, /recall) |
| Commands | `.claude/commands/*.md` | Slash commands |
| Hooks | `.claude/hooks/*.md` | Event triggers |

**MCP Integration**: `~/.config/claude-code/settings.json`

### Cursor

**Config location**: `~/.cursor/` (symlinked)

| Component | Path | Purpose |
|-----------|------|---------|
| Agents | `.cursor/agents/*.md` | Custom agent definitions |
| Skills | `.cursor/skills/*/SKILL.md` | Invokable skills |
| Rules | `.cursor/rules/*.mdc` | Context rules for the AI |

**MCP Integration**: `~/.cursor/mcp.json`

---

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

### Atomic Writes

**Script**: `scripts/atomic-write.sh`

Prevents file corruption during concurrent access:

```bash
# Write JSON atomically with validation and backup
echo '{"data": "value"}' | ~/aiconfig/scripts/atomic-write.sh /path/to/file.json --backup
```

How it works:
1. Writes content to temp file in same directory
2. Validates JSON (auto-detected for `.json` files)
3. Creates backup if `--backup` flag is set
4. Atomically renames temp file to target (POSIX `mv` is atomic on same filesystem)

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

---

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

### Portable Skills

Skills are defined in `SKILL.md` format and work across both clients:

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `/init-memory` | Initialize project memory | Start of new project |
| `/log-session` | Record session to memory | End of coding session |
| `/recall` | Search past context | Finding previous work |

**Skill structure**:
```
.claude/skills/
└── init-memory/
    └── SKILL.md
.cursor/skills/
└── init-memory/
    └── SKILL.md
```

### Custom Agents

| Agent | Purpose |
|-------|---------|
| `context-manager` | Information storage and retrieval |
| `memory-manager` | Session and decision management |
| `knowledge-synthesizer` | Pattern extraction and learning |

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
