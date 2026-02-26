# Domain Architecture Reference: MCP (Model Context Protocol)

## Overview

MCP is a protocol for connecting AI models to external tools, data sources, and capabilities. Architecturally, it defines how AI agents discover and invoke tools, how context flows between models and systems, and how agent capabilities are composed and extended. It's the integration layer between AI and your infrastructure.

---

## Key Architectural Decisions

### Decision 1: MCP Server Topology

**Context:** How MCP servers are organized, deployed, and discovered.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| One MCP server per tool/integration | Clear boundaries, independent deployment | Many servers to manage, discovery overhead |
| Domain-aggregated servers (one per bounded context) | Related tools grouped logically (e.g., "git-server" handles all git ops) | Larger servers, changes to one tool redeploy the group |
| Single monolithic MCP server | Small system, few tools, simplicity | Couples all tools, scaling/deployment is all-or-nothing |
| Gateway + backend servers | Want unified discovery with distributed implementation | Gateway is a chokepoint, additional hop |
| Sidecar MCP servers (per agent) | Each agent has dedicated tools, no sharing needed | Duplication if multiple agents need same tools |

### Decision 2: Transport and Hosting

**Context:** How MCP servers communicate with clients (AI models/agents).

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| stdio (local process) | Local development, Claude Code, single-user tools | No network, not shareable, one client per server |
| SSE (Server-Sent Events) over HTTP | Remote servers, multi-client, web-compatible | Unidirectional streaming, HTTP overhead |
| Streamable HTTP | Modern MCP transport, bidirectional, stateless-friendly | Newer transport, check client support |
| WebSocket | Low-latency bidirectional, long-lived connections | Connection management, scaling stateful connections |
| Container-per-request (serverless MCP) | Isolation per invocation, auto-scaling | Cold start latency, no persistent state between calls |

### Decision 3: Tool Granularity

**Context:** How fine-grained or coarse-grained individual MCP tools should be.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Fine-grained (one action per tool) | Composable, model can chain tools flexibly | More tools for model to choose from, token overhead in tool listing |
| Coarse-grained (workflow per tool) | Complex multi-step operations that always go together | Less flexible, model can't customize intermediate steps |
| Resource-oriented (CRUD per entity) | Data access patterns, REST-like mental model | May not fit non-CRUD operations well |
| Capability-oriented (tools grouped by what they enable) | Agent capabilities map to business functions | Harder to reuse across different agent contexts |
| Adaptive (dynamic tool listing based on context) | Large tool libraries, context-dependent availability | Dynamic discovery complexity, harder to test |

### Decision 4: Authentication and Authorization

**Context:** How MCP servers authenticate callers and authorize tool access.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| No auth (trusted environment) | Local stdio, internal network only | No security boundary, not suitable for shared/remote servers |
| API key per server | Simple, per-server access control | Key management, rotation, no user-level granularity |
| OAuth 2.0 / OIDC | User-delegated access, enterprise SSO integration | More complex, token lifecycle management |
| Per-tool authorization (RBAC) | Different agents/users need different tool access | Authorization logic in every tool, maintenance overhead |
| Mutual TLS | Service-to-service in zero-trust environment | Certificate management, development friction |

### Decision 5: State and Context Management

**Context:** How state persists across tool invocations within an agent session.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Stateless tools (all context in request) | Simple, scalable, no server-side state | Larger payloads, redundant context passing |
| Session-scoped state (server maintains session) | Multi-step workflows needing intermediate state | Server must track sessions, scaling is harder |
| External state store (Redis, DB) | Shared state across servers, persistence needed | Additional infrastructure, latency |
| Context passed through model (model remembers) | Simple interactions, model handles continuity | Limited by context window, model may lose track |
| Hybrid (stateless tools + model-managed context) | Most common balanced approach | Requires clear contract on what lives where |

### Decision 6: Agent-to-MCP Composition

**Context:** How agents are composed from MCP capabilities — especially when multiple agents need overlapping tools.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Agent specifies exact MCP servers | Simple, explicit, predictable | Manual wiring per agent, duplication across agents |
| Agent role → MCP capability mapping | Roles define which tools are available (e.g., "reviewer" gets read-only tools) | Role definition overhead, role explosion |
| Dynamic tool discovery (registry) | Large tool ecosystem, agents discover what's available | Discovery latency, harder to predict agent behavior |
| MCP server composition (server wraps other servers) | Want to create higher-level tool APIs from lower-level ones | Composition complexity, debugging through layers |

---

## Pattern Options

### Pattern 1: Tool-per-Integration

**What it is:** Each external system (GitHub, Slack, database, K8s) gets its own MCP server with tools scoped to that integration.
**When to use:** Clear ownership per integration, independent scaling and deployment.
**When to avoid:** When the overhead of many servers isn't justified by the number of integrations.
**Combines well with:** Kubernetes (each server is a service), ArgoCD (independent deployment).

### Pattern 2: Agent Toolkit Pattern

**What it is:** Pre-composed sets of MCP servers designed for specific agent roles (e.g., "support agent toolkit" = customer DB + ticket system + knowledge base).
**When to use:** Multiple specialized agents, want predictable tool sets per role.
**When to avoid:** When agents need highly dynamic tool access.
**Combines well with:** Agent sub-agent architectures, RBAC-based tool access.

### Pattern 3: MCP Gateway

**What it is:** A single MCP endpoint that routes tool calls to backend MCP servers. Clients connect to one gateway, gateway handles discovery and routing.
**When to use:** Many tools, want simplified client config, centralized auth/logging.
**When to avoid:** Simple setups with few servers, when gateway latency is unacceptable.
**Combines well with:** Kubernetes ingress patterns, API gateway patterns.

### Pattern 4: Resource-First MCP Design

**What it is:** MCP servers expose resources (documents, records, configs) as first-class MCP resources, with tools for querying and mutating them. Model can read resources for context before invoking tools.
**When to use:** Data-rich integrations where the model needs to understand state before acting.
**When to avoid:** Action-only integrations (fire webhooks, send messages) where there's no meaningful state to read.
**Combines well with:** Data platform domain, knowledge base integrations.

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| God MCP server | One server with 50+ tools covering every integration | Tool list overwhelms model, slow to load, impossible to maintain | Split by integration or domain, use gateway if needed |
| Leaky abstractions in tools | Tool returns raw database rows or API responses without processing | Model wastes tokens parsing raw data, error-prone | Tools should return clean, structured, model-friendly responses |
| No error handling | Tools throw exceptions that bubble as opaque errors | Model can't recover or retry intelligently | Return structured error responses with actionable messages |
| Stateful tools without cleanup | Server accumulates session state with no expiry | Memory leaks, stale state affects later calls | Session TTLs, explicit cleanup tools, or stateless design |
| Tool description neglect | Vague or missing tool descriptions | Model picks wrong tools, misuses parameters | Detailed descriptions with parameter constraints and examples |
| Direct infrastructure exposure | Tools that let the model run arbitrary SQL or kubectl commands | Security risk, blast radius is unlimited | Purpose-built tools with guardrails, not raw infrastructure access |

---

## Fitness Functions

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| All tools have descriptions | Model can select tools correctly | Lint MCP server tool definitions for non-empty descriptions |
| Tool response size bounds | No tools returning unbounded data | Test tools with large datasets, enforce max response size |
| Auth on all remote servers | No unauthenticated tool access in production | Security scan of MCP server configs |
| Error handling coverage | All tools return structured errors | Test each tool with invalid inputs, verify error format |
| Tool latency budget | Tools respond within acceptable time for agent UX | Load test MCP servers, set p95 latency thresholds |
| Integration test per tool | Tools actually work against their backends | CI integration tests per MCP server |

## Decision Checklist

Before finalizing MCP architecture:

- [ ] MCP server topology defined (per-integration, aggregated, gateway)
- [ ] Transport chosen per deployment context (stdio local, SSE/HTTP remote)
- [ ] Tool granularity strategy consistent across servers
- [ ] Authentication and authorization approach defined
- [ ] State management strategy documented (stateless vs session-scoped)
- [ ] Agent-to-MCP wiring approach chosen
- [ ] Error handling contract defined (structured error format)
- [ ] Tool descriptions reviewed for clarity and accuracy
- [ ] Monitoring and logging in place for tool invocations
- [ ] Security review of tool capabilities (blast radius assessment)