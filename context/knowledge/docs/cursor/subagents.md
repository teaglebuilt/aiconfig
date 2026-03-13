# Cursor Subagents

Source: https://cursor.com/docs/subagents

## What are Subagents

Subagents allow the main agent to delegate tasks.

Example:

Main agent task:

```
Build authentication system
```

Subtasks may be delegated:

* database schema
* API implementation
* frontend integration
* tests

Each subagent focuses on a specific job.

## Benefits

* Parallel task execution
* Specialized reasoning
* Better organization

## Example Flow

Main Agent:

```
Implement OAuth login
```

Subagents:

1. OAuth provider setup
2. Backend routes
3. Frontend UI
4. Integration tests

## Configuration

Subagents can be defined in configuration files.

Example concept:

```
agents:
  - name: backend-agent
  - name: frontend-agent
```

## When to Use

Subagents are useful for:

* Large feature development
* Multi-step refactors
* Complex systems
