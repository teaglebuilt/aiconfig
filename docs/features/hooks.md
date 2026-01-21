# Hooks

On install of `aiconfig` the hooks like everything else, are setup and configured to work between cursor and claude code.

## Hook Events

**Tool Events**

- before:
  - claude-code: `PreToolUse` - [Input Schema](https://code.claude.com/docs/en/hooks#pretooluse-input)
  - cursor: `beforeShellExecution` - [Input Schema](https://cursor.com/docs/agent/hooks#beforeshellexecution-beforemcpexecution)
- after:
  - claude-code: `PostToolUse` - [Input Schema](https://code.claude.com/docs/en/hooks#posttooluse-input)
  - cursor: `afterShellExecution` - [Input Schema](https://cursor.com/docs/agent/hooks#aftershellexecution)

**SessionEvents**
  - start:
    - claude-code: `sessionStart`
    - cursor: `sessionStart`
  - end:
    - claude-code: `sessionEnd`
    - cursor: `sessionEnd`

#### References

- [Cursor Hooks](https://cursor.com/docs/agent/hooks)
- [Claude Code Hooks](https://code.claude.com/docs/en/hooks)
