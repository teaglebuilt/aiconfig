# Skills

Skills are reusable prompts that extend agent capabilities. They are the **primary extension mechanism** for Claude Code and are also discovered by Cursor.

> Custom slash commands have been merged into skills. Files in `.claude/commands/` still work, but skills are recommended for new development. See [Commands](./commands.md) for the distinction.

## Available Skills

| Skill | Description | Side Effects |
|-------|-------------|--------------|
| `/init-memory` | Initialize project memory structure with context, session, and decision tracking | Writes files |
| `/log-session` | Record session accomplishments, decisions, and follow-ups to project memory | Writes files |
| `/recall` | Search project memory for past decisions, similar problems, or session history | Read-only |
| `/generate-prd` | Generate a Product Requirements Document for a feature | Writes files |
| `/generate-prd-to-json` | Convert a PRD to Ralph autonomous agent JSON format | Writes files |
| `/architect` | Deep architecture analysis, pattern evaluation, and decision documentation | Read-only |
| `/claude-code` | Claude Code architecture — hooks, observability, agent workflows, configuration patterns | Read-only |

## Skill Discovery

Skills are auto-discovered from these locations (highest priority first):

| Location | Scope | Discovered By |
|----------|-------|---------------|
| Enterprise managed settings | Organization | Claude Code |
| `~/.claude/skills/` | Personal (all projects) | Claude Code, Cursor |
| `.claude/skills/` | Project | Claude Code, Cursor |
| Nested `.claude/skills/` in subdirs | Package (monorepo) | Claude Code |

Both clients discover `.claude/skills/` — **do not duplicate skills into `.cursor/skills/`**.

## Skill Structure

```
.claude/skills/
├── init-memory/SKILL.md        # Memory initialization
├── log-session/SKILL.md        # Session logging
├── recall/SKILL.md             # Memory search
├── generate-prd/SKILL.md       # PRD generation
├── generate-prd-to-json/SKILL.md  # PRD to JSON conversion
├── architect/                   # Architecture analysis
│   ├── SKILL.md                 # Entry point
│   ├── references/              # Analysis frameworks
│   └── templates/               # Output templates
└── claude-code/                 # Claude Code architecture
    ├── SKILL.md                 # Entry point
    └── references/              # Hooks, observability, orchestration
```

Each skill is a directory with `SKILL.md` as the entry point. Additional files (templates, scripts, reference docs) can live alongside it — reference them from `SKILL.md` so Claude knows when to load them.

## Frontmatter Reference

```yaml
---
name: my-skill                    # Slash command name (defaults to directory name)
description: What this skill does  # How Claude decides when to use it
disable-model-invocation: true     # Only user can invoke (prevents auto-invocation)
user-invocable: false              # Only Claude can invoke (hides from / menu)
allowed-tools: Read, Grep, Glob   # Restrict tool access when skill is active
context: fork                      # Run in isolated subagent
agent: Explore                     # Subagent type (when context: fork)
argument-hint: "[search query]"    # Autocomplete hint for arguments
model: sonnet                      # Model override for this skill
---
```

All fields are optional. Only `description` is recommended.

### Key Frontmatter Decisions

| Scenario | Frontmatter |
|----------|-------------|
| Skill writes files (init-memory, log-session) | `disable-model-invocation: true` |
| Background knowledge, not a user action | `user-invocable: false` |
| Read-only information gathering | `allowed-tools: Read, Grep, Glob` |
| Heavy analysis that shouldn't pollute context | `context: fork` with `agent: Explore` |
| Skill accepts user input | Use `$ARGUMENTS` in content, add `argument-hint` |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke |
|-------------|----------------|-------------------|
| (default) | Yes | Yes |
| `disable-model-invocation: true` | Yes | No |
| `user-invocable: false` | No | Yes |

## String Substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed after `/skill-name` |
| `$ARGUMENTS[N]` or `$N` | Specific argument by index (0-based) |
| `${CLAUDE_SESSION_ID}` | Current session ID |

## Dynamic Context Injection

Use `` !`command` `` to run shell commands before the skill content reaches Claude:

```yaml
---
name: status
description: Show current project status
---
## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`

Summarize the current project state.
```

The command output replaces the placeholder — Claude receives data, not the command.

## Memory Skills Workflow

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

## References

- [Claude Code Skills Docs](https://code.claude.com/docs/en/skills) — canonical reference
- [Agent Skills Open Standard](https://agentskills.io) — cross-tool skill format
- [Commands](./commands.md) — legacy command format (still supported)
