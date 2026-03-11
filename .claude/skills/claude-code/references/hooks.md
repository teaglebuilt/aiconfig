# Claude Code Hook System Reference

## Hook Types

| Hook | Interception Point | Use When |
|------|-------------------|----------|
| PreToolUse | Before tool execution | Validation, permission checking, command blocking |
| PostToolUse | After tool execution | Result logging, metrics collection, cleanup |
| UserPromptSubmit | Before Claude processes input | Input preprocessing, context enrichment |
| Notification | User interaction events | Analytics, external notifications |
| Stop / SubagentStop | Agent completion | Session lifecycle management, cleanup |
| PreCompact | Before context compression | Context optimization, state preservation |
| SessionStart / SessionEnd | Session lifecycle | Initialization and teardown |

## Hook Selection Strategy

**Use PreToolUse When:**
- Need to validate or block dangerous operations
- Require permission checks before execution
- Want to modify tool inputs before execution
- **Criteria:** Synchronous validation, security-critical, <100ms execution

**Use PostToolUse When:**
- Need to log results or collect metrics
- Want to trigger follow-up actions
- Analyzing tool outputs for patterns
- **Criteria:** Asynchronous processing OK, observability focus

**Use UserPromptSubmit When:**
- Enriching user input with context
- Preprocessing queries for better results
- Tracking user intent patterns
- **Criteria:** Runs before Claude processes input

**Use SessionStart/SessionEnd When:**
- Initializing per-session resources
- Cleaning up session state
- Session-level analytics and tracking
- **Criteria:** Lifecycle management, setup/teardown

## Hook Architecture Pattern

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

import sys
import json

def process_event(event_data: dict) -> dict:
    """
    Process hook event with proper error handling.

    Returns:
        dict: Response with 'decision', 'systemMessage', 'hookSpecificOutput'
    """
    try:
        if should_block(event_data):
            return {
                "decision": "block",
                "systemMessage": "Operation blocked: reason here"
            }
        return {
            "decision": "allow",
            "systemMessage": "Optional feedback message"
        }
    except Exception as e:
        # Graceful degradation - never block on hook errors
        return {
            "decision": "allow",
            "systemMessage": f"Hook warning: {str(e)}"
        }

if __name__ == "__main__":
    event = json.loads(sys.stdin.read())
    response = process_event(event)
    print(json.dumps(response))
```

## Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "/path/to/.claude/hooks/validate_command.py"
      }
    ],
    "PostToolUse": [
      {
        "command": "/path/to/.claude/hooks/log_tool_use.py"
      }
    ]
  }
}
```

## Safety Validation Example

```python
import re

DANGEROUS_PATTERNS = [
    r'rm\s+-rf\s+/',
    r'dd\s+if=.*of=/dev/',
    r'mkfs\.',
]

def validate_command_safety(tool_input: dict) -> bool:
    command = tool_input.get('command', '')
    for pattern in DANGEROUS_PATTERNS:
        if re.search(pattern, command):
            return False
    return True

def process_pretooluse_event(event: dict) -> dict:
    tool_input = event.get('tool_input', {})
    if not validate_command_safety(tool_input):
        return {
            "hookSpecificOutput": {
                "permissionDecision": "deny",
                "permissionDecisionReason": "Dangerous command blocked"
            }
        }
    return {
        "hookSpecificOutput": {
            "permissionDecision": "allow"
        }
    }
```

## Testing Hooks

```bash
# Test hook with sample event
echo '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' | \
  .claude/hooks/pre_tool_use.py
```
