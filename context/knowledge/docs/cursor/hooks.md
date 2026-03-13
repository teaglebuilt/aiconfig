# Cursor Hooks

Source: https://cursor.com/docs/hooks

## Overview

Hooks allow you to extend the agent loop with custom scripts.

Hooks can:

* Observe agent activity
* Modify behavior
* Integrate external systems

Hooks run as separate processes and communicate via JSON over standard IO.

## Hook Lifecycle

Typical hook points:

* before action
* after action
* completion

## Use Cases

* Logging agent actions
* Integrating CI checks
* Enforcing policies
* Custom automation

Example:

```
Run lint checks after file edits
```

## Example Hook Script

Example pseudo implementation:

```
#!/usr/bin/env node

process.stdin.on("data", data => {
  const event = JSON.parse(data)

  if(event.type === "file_edit"){
     console.log("File edited:", event.path)
  }
})
```

## Security

Hooks should:

* Validate inputs
* Limit command execution
* Avoid exposing secrets

## Configuration

Hooks are configured in project settings or configuration files.
