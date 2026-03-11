# Agent Orchestration Patterns

## Multi-Agent Workflow Types

| Pattern | Description | When to Use |
|---------|------------|-------------|
| Sequential | Task A -> Task B -> Task C | Dependency chain where each step needs prior output |
| Parallel | Task A \|\| Task B \|\| Task C | Independent tasks that can run concurrently |
| Hierarchical | Coordinator -> [Specialist 1, 2, ...] | Complex tasks requiring different expertise areas |
| Reactive | Event-driven agent invocation | Tasks triggered by external events or conditions |

## Coordination Mechanisms

```typescript
interface AgentTask {
  id: string;
  type: string;
  input: unknown;
  dependencies: string[];
}

interface AgentCoordinator {
  delegate(task: AgentTask, agentType: string): Promise<Result>;
  waitForAll(taskIds: string[]): Promise<Result[]>;
  raceAgents(task: AgentTask, agentTypes: string[]): Promise<Result>;
}
```

## Claude Code Agent Types

| Agent Type | Best For | Context Impact |
|-----------|---------|----------------|
| Explore | Fast codebase search, file discovery | Minimal - results summarized back |
| Plan | Architecture planning, implementation strategy | Minimal - returns plan only |
| General-purpose | Complex multi-step tasks | Moderate - full tool access |
| Custom (via agents/) | Domain-specific expertise | Depends on skill's `context:` setting |

## Skill-Agent Pair Pattern

The recommended pattern for complex tasks:

```
Skill (SKILL.md)          Agent (agent-name.md)
├── Entry point            ├── Persona & principles
├── Procedures             ├── Reasoning approach
├── Routing tables         ├── Communication style
├── Knowledge loading      └── Anti-patterns to watch
└── References/templates
```

- **Skill** = what to do, what to read, routing logic
- **Agent** = how to think, persona, judgment principles
- Skill references agent via `agent:` frontmatter
- Agent does NOT reference the skill (avoids circular dependency)

## Context Management

| Setting | Behavior | Use When |
|---------|----------|----------|
| `context: fork` | Runs in isolated subagent | Heavy tasks loading many files |
| `context: inline` (default) | Runs in main conversation | Quick lookups, simple operations |

Fork is recommended when:
- The task loads 3+ knowledge files
- Output is a structured document (ADR, report)
- You want to keep the main conversation clean
