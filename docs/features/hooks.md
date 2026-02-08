# Hooks

Cursor has built-in compatibility with Claude Code hooks. Define hooks once in `.claude/settings.json` and both clients will use them.

## Cross-Client Compatibility

**Cursor reads Claude Code hooks natively.** Enable "Third-party skills" in Cursor Settings > Features.

### Configuration Priority

Hooks load from these locations (highest to lowest priority):

1. `.cursor/hooks.json` (project)
2. `~/.cursor/hooks.json` (user)
3. `.claude/settings.local.json` (project local)
4. `.claude/settings.json` (project)
5. `~/.claude/settings.json` (user)

**Recommendation:** Define hooks in `.claude/settings.json` for single-source configuration.

## Hook Name Mapping

Cursor automatically translates Claude Code hook names:

| Claude Code | Cursor |
|-------------|--------|
| `PreToolUse` | `preToolUse` |
| `PostToolUse` | `postToolUse` |
| `UserPromptSubmit` | `beforeSubmitPrompt` |
| `sessionStart` | `sessionStart` |
| `sessionEnd` | `sessionEnd` |

## Hook Events

### Tool Events

| Event | When | Use Case |
|-------|------|----------|
| `PreToolUse` | Before tool execution | Validate, log, block dangerous commands |
| `PostToolUse` | After tool execution | Log results, trigger follow-up actions |

### Session Events

| Event | When | Use Case |
|-------|------|----------|
| `sessionStart` | Session begins | Load context, initialize state |
| `sessionEnd` | Session ends | Save context, log session summary |

## Example Configuration

In `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Shell",
        "command": "~/aiconfig/scripts/hook-handler.sh before-tool"
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "command": "~/aiconfig/scripts/hook-handler.sh after-tool"
      }
    ],
    "sessionEnd": [
      {
        "command": "echo 'Consider running /log-session to save context'"
      }
    ]
  }
}
```

## Exit Codes

Both clients recognize these exit codes:

| Code | Behavior |
|------|----------|
| `0` | Allow action to proceed |
| `2` | Block/deny the action |
| Other | Allow (with warning) |

## Limitations

Cursor doesn't support these Claude Code events:
- `Notification`
- `PermissionRequest`

Claude Code doesn't support these Cursor events:
- `subagentStart`
- Team dashboard distribution

## References

- [Cursor Hooks](https://cursor.com/docs/agent/hooks)
- [Cursor Third-Party Hooks](https://cursor.com/docs/agent/third-party-hooks)
- [Claude Code Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks)
