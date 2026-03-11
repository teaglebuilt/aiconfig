### Agents

Agents are specialized personas with domain expertise and predefined tools.

[Cursor Agents](https://cursor.com/docs/context/subagents)
[Claude Code Agents](https://code.claude.com/docs/en/sub-agents)

#### Available Agents

| Agent | Description | Tools | Paired Skill |
|-------|-------------|-------|-------------|
| `architect-agent` | Architecture advisor, pattern evaluation, tradeoff analysis | Read, Edit, Write, Bash, Grep, WebSearch | `/architect` |
| `developer-agent` | Implementation specialist, coding standards, test-driven development | Read, Edit, Write, Bash, Grep, Glob | `/developer` |
| `claude-code-agent` | Claude Code architecture — hooks, observability, agent workflows | Read, Edit, Write, Bash, Grep, WebSearch | `/claude-code` |
| `memory-manager` | Session logging, decision recording, context maintenance | Read, Write, Glob, Grep | — |

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
├── architect-agent.md       # Paired with /architect skill
├── developer-agent.md       # Paired with /developer skill
├── claude-code-agent.md     # Paired with /claude-code skill
└── memory-manager.md        # Standalone agent

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
| Role | Persona — *how to think* | Procedures — *what to do and read* |
| Content | Reasoning principles, communication style, anti-patterns | Routing tables, procedures, references, templates |
| Invocation | Cannot be invoked directly; attached via skill frontmatter | `/skill-name` by user or auto-triggered by Claude |
| Size target | 60-90 lines (persona only) | Variable (procedures + routing tables) |

#### Skill-Agent Pair Pattern

The recommended pattern for complex tasks:

```
Skill (SKILL.md)                Agent (agent-name.md)
├── Frontmatter (agent: name)   ├── Persona & principles
├── Procedures                  ├── Reasoning approach
├── Routing tables              ├── Communication style
├── references/                 └── Anti-patterns to watch
└── templates/
```

**Key rules:**
- Skill references agent via `agent:` frontmatter — agent does NOT reference the skill
- Routing tables live in the skill only (single source of truth)
- Agents should not contain reference material, code examples, or pattern catalogs

#### Key Agents

**architect-agent** (paired with `/architect`)
- Senior software architect persona
- Evaluates patterns without bias
- Produces ADRs, tradeoff analyses, C4 diagrams

**developer-agent** (paired with `/developer`)
- Implementation specialist persona
- Follows established patterns, writes tests
- Self-reviews against coding standards

**claude-code-agent** (paired with `/claude-code`)
- Claude Code architecture specialist
- Hooks, observability, agent workflows
- Configuration pattern evaluation

**memory-manager** (standalone)
- Maintains aiconfig project memory
- Logs coding sessions
- Records architectural decisions
