# Claude Code Observability Reference

## Instrumentation Layers

1. **Event Collection:** Hook execution, tool calls, agent interactions
2. **Metrics Aggregation:** Latency, token usage, error rates, session duration
3. **Log Correlation:** Distributed tracing across hooks, agents, and services
4. **Alerting:** Threshold-based alerts for anomalies and failures

## Recommended Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Storage | PostgreSQL / TimescaleDB | Structured events, time-series |
| Transport | HTTP REST + WebSocket | Real-time streaming |
| Visualization | Grafana / custom Next.js | Dashboards |
| Analysis | SQL / aggregation pipelines | Custom analytics |

## Key Metrics

### Performance
- Hook Execution Time (p50, p95, p99): <100ms target
- Tool Call Latency: By tool type and complexity
- Session Duration: Track user engagement patterns

### Quality
- Hook Success Rate: >99.9% (hooks should never block user flow)
- Error Rate: By hook type and event type
- Block Decision Rate: Track safety interventions

### Usage
- Events Per Session: Understand interaction patterns
- Tool Usage Distribution: Identify most-used tools
- Agent Invocation Frequency: Track agent effectiveness

### Cost
- Token Consumption: By session, by tool, by agent
- API Costs: Track spending across providers
- Infrastructure Costs: Server, database, storage

## Event Schema

```typescript
interface HookEvent {
  session_id: string;
  hook_event_type: string;
  timestamp: string;
  payload: {
    tool_name?: string;
    tool_input?: unknown;
    tool_output?: unknown;
    error?: string;
  };
  metadata: {
    hook_execution_time_ms: number;
    decision?: 'allow' | 'block';
  };
}
```

## Alert Rules

```yaml
High Error Rate:
  condition: error_rate > 5% over 5m
  action: notify_team

Hook Performance Degradation:
  condition: p95_latency > 200ms over 10m
  action: investigate

Unusual Block Rate:
  condition: block_rate > 10% over 5m
  action: review_safety_rules
```

## Implementation Steps

1. **Design Event Schema** - Define what to capture per hook type
2. **Implement Event Collection** - HTTP endpoint for event ingestion, database schema
3. **Build Monitoring Dashboard** - Real-time event stream, session filtering, metrics charts
4. **Set Up Alerting** - Threshold-based alerts with escalation policies
