# Commands

## Status: Legacy (Still Supported)

Custom slash commands (`.claude/commands/*.md`) have been **merged into skills**. Both paths create the same `/slash-command` and support the same frontmatter. Your existing command files continue to work.

> A file at `.claude/commands/review.md` and a skill at `.claude/skills/review/SKILL.md` both create `/review` and work the same way.
>
> — [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

## Commands vs Skills

| Capability | Commands (`.claude/commands/`) | Skills (`.claude/skills/`) |
|------------|-------------------------------|---------------------------|
| `/slash-command` invocation | Yes | Yes |
| YAML frontmatter | Yes | Yes |
| `$ARGUMENTS` substitution | Yes | Yes |
| `context: fork` (subagent) | Yes | Yes |
| Supporting files (templates, scripts) | No | Yes |
| Directory-based organization | No | Yes |
| Auto-discovery by Cursor | No | Yes |

**Precedence**: If a skill and command share the same name, the skill takes precedence.

## When to Use Commands

Commands are appropriate for **simple, single-file prompts** that don't need supporting files or cross-client discovery. They're a lightweight option when you want a quick slash command without creating a directory structure.

Current commands in this project:

| Command | Purpose |
|---------|---------|
| `/execute-prd` | Implement a user story from a PRD |
| `/market-expand` | Expand a market segment into hierarchical niches |
| `/market-gap` | Generate business solutions using strategic frameworks |
| `/pain-points` | Extract pain points from forum discussions |
| `/youtube` | Manage YouTube channel subscriptions |

## When to Use Skills Instead

Prefer skills (`.claude/skills/<name>/SKILL.md`) when:

- The prompt needs **supporting files** (templates, scripts, examples, reference docs)
- You want **cross-client discovery** (Cursor auto-discovers `.claude/skills/`)
- You need **invocation control** (`disable-model-invocation`, `user-invocable`)
- You want **tool restrictions** (`allowed-tools` for read-only mode)
- You need **subagent execution** with a specific agent type (`context: fork`, `agent: Explore`)
- The skill is part of a **shared workflow** used by the team

## Migration Path

No migration is required — commands keep working indefinitely. To migrate a command to a skill:

```
# Before: .claude/commands/my-command.md
# After:  .claude/skills/my-command/SKILL.md
```

The file content and frontmatter stay the same. You gain the ability to add supporting files in the skill directory.

## References

- [Claude Code Skills Docs](https://code.claude.com/docs/en/skills) — canonical reference (covers both commands and skills)
