---
name: claude-code
description: Expert guidance on Claude Code architecture — hooks, observability, agent workflows, skill design, and configuration patterns.
context: fork
agent: claude-code-agent
model: opus
---

# Claude Code Architecture Skill

> Use this skill when designing Claude Code configurations, implementing hooks, setting up observability, designing agent workflows, or evaluating Claude Code architecture patterns.

## Claude Code Documentation

#### `context/knowledge/docs/claude_code

| File | When to Load |
|------|-------------|
| `best_practices` | Always read first |
| `features_overview.md` | Always read second |
| `claude-code-sub-agents.md` | When discussing agents |
| `claude-code-agent-teams.md` | When discussing agent orchestration |

## Procedures

This skill provides four core capabilities. Load the relevant resource before executing.

### 1. Design a Hook

When implementing a Claude Code hook:

1. Read `references/hooks.md` for hook types, selection strategy, and architecture patterns
2. Read `references/quality-gates.md` for implementation standards
3. Determine the appropriate hook type (PreToolUse, PostToolUse, SessionStart, etc.)
4. Design the hook with graceful degradation (never block on errors)
5. Provide implementation with proper error handling and structured logging
6. Include testing instructions

### 2. Set Up Observability

When designing monitoring and observability for Claude Code:

1. Read `references/observability.md` for the full instrumentation framework
2. Read `references/quality-gates.md` for performance targets
3. Identify which metrics matter most for the use case
4. Design the event collection and storage strategy
5. Recommend dashboard and alerting configuration

### 3. Design Agent Workflow

When architecting agent orchestration or skill-agent pairs:

1. Read `references/orchestration.md` for workflow patterns and coordination mechanisms
2. Read `references/decision-frameworks.md` for agent vs skill boundary decisions
3. Assess the task complexity and determine the right pattern (sequential, parallel, hierarchical)
4. Design the skill-agent pair structure if needed
5. Recommend context management strategy (fork vs inline)

### 4. Evaluate Claude Code Configuration

When reviewing or improving a Claude Code setup:

1. Read `references/decision-frameworks.md` for anti-patterns and decision matrices
2. Read `references/orchestration.md` for the skill-agent pair pattern
3. Audit the current configuration against anti-patterns
4. Check routing table consistency (do referenced files exist?)
5. Assess knowledge organization and loading efficiency
6. Provide prioritized recommendations

---

## Resource Routing

### Skill References

| Task | Resource to Read |
|------|-----------------|
| Implementing hooks | `references/hooks.md` |
| Setting up monitoring | `references/observability.md` |
| Designing agent workflows | `references/orchestration.md` |
| Evaluating configuration | `references/decision-frameworks.md` |
| Checking quality standards | `references/quality-gates.md` |

### Domain Knowledge

When the task involves Claude Code in the broader context of the aiconfig system, also load:

| File | When to Load |
|------|-------------|
| `context/knowledge/architecture/ai/claude-code.md` | Architectural decisions about Claude Code configuration |
| `context/knowledge/architecture/ai/mcp.md` | MCP server integration with Claude Code |
