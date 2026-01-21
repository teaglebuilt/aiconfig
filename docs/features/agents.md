### Agents

Agents are specialized personas with domain expertise and predefined tools.

#### Available Agents

| Agent | Description | Tools |
|-------|-------------|-------|
| `context-manager` | Information storage, retrieval, synchronization | Read, Write, redis, elasticsearch, vector-db |
| `memory-manager` | Session logging, decision recording, context maintenance | Read, Write, Glob, Grep |

#### Agent Discovery

Agents are discovered from these locations:

| Location | Scope | Client |
|----------|-------|--------|
| `.claude/agents/` | Project | Claude Code |
| `.cursor/agents/` | Project | Cursor |
| `~/.claude/agents/` | Global | Claude Code |
| `~/.cursor/agents/` | Global | Cursor |

#### Agent Structure

```
.claude/agents/              # Claude Code agents
├── context-manager.md
└── memory-manager.md

.cursor/agents/              # Cursor agents
├── context-manager.md
└── memory-manager.md
```

#### Agent Format

```markdown
---
name: agent-name
description: What this agent specializes in. Triggers on: keyword1, keyword2.
tools: Tool1, Tool2, Tool3
---

You are a [role] specialist with expertise in [domain].

## When Invoked
1. Step one
2. Step two

## Responsibilities
- Responsibility 1
- Responsibility 2

## Integration
Works with other agents and skills.
```

#### Agent vs Skill

| Aspect | Agent | Skill |
|--------|-------|-------|
| Scope | Broad domain expertise | Single focused task |
| Persistence | Maintains context throughout session | Executes and completes |
| Tools | Has access to specific toolset | Uses available tools |
| Invocation | `@agent-name` or auto-triggered | `/skill-name` or triggers |

#### Key Agents

**context-manager**
- Manages information storage and retrieval
- Handles synchronization across systems
- Optimizes query performance
- Ensures data consistency

**memory-manager**
- Maintains aiconfig project memory
- Logs coding sessions
- Records architectural decisions
- Updates project context
