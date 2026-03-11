# Domain Architecture Reference: Cloudflare Workers

> Architectural decisions for building applications on Cloudflare's serverless edge compute platform.

---

## Overview

Cloudflare Workers is a serverless platform running on V8 isolates across Cloudflare's global network (~300 data centers). Workers execute JavaScript/TypeScript/Python/Rust at the edge with no cold starts, no infrastructure management, and automatic global deployment.

---

## Key Architectural Decisions

### Decision 1: Workers vs Pages

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Workers | APIs, background jobs, stateful apps, custom routing, bindings-heavy workloads | More configuration, no built-in CI/CD |
| Pages | Static sites, JAMstack, framework-based full-stack apps (Next.js, Astro, React Router) | Less flexibility, opinionated build pipeline |
| Workers + Static Assets | Full-stack apps that need both static serving and dynamic compute | Single deployment unit, static assets served from CDN/cache for free |

### Decision 2: Storage Selection

| Use Case | Product | Consistency | Ideal For |
|----------|---------|-------------|-----------|
| Key-value storage | **KV** | Eventually consistent | Config data, session storage, A/B testing, routing metadata. High read volume, low write frequency |
| Object/blob storage | **R2** | Strong (per-object) | Files, images, ML datasets, logs. S3-compatible, zero egress fees |
| Relational data | **D1** | Strong (read replicas available) | User profiles, product listings, orders. Lightweight serverless SQLite |
| Stateful coordination | **Durable Objects** | Strongly consistent, transactional | Real-time collaboration, chat, game servers, WebSocket apps. Single-threaded per object |
| External database | **Hyperdrive** | Depends on upstream DB | Connecting to existing Postgres/MySQL with connection pooling and edge caching |
| Message queuing | **Queues** | At-least-once delivery | Background jobs, inter-service communication, event buffering |
| Vector search | **Vectorize** | — | AI embeddings, semantic search, RAG workflows |
| Time-series metrics | **Analytics Engine** | — | Custom analytics, usage-based billing, telemetry |
| Streaming ingestion | **Pipelines** | — | High-throughput data ingestion to R2 |

### Decision 3: D1 vs Durable Objects SQL

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| D1 | Familiar managed database model, need HTTP API access, schema migrations, data import/export, query insights | Code and DB not colocated (network hop), max 10GB per database |
| Durable Objects SQLite | Need code colocated with storage, building distributed systems, per-user/per-tenant databases | Must build own tooling, Workers-only access, more implementation effort |
| Hyperdrive | Already have Postgres/MySQL, need 1TB+ databases, want existing DB tools | Depends on external database availability, added hop to origin |

### Decision 4: Execution Model

| Aspect | Detail |
|--------|--------|
| Runtime | V8 isolates (not containers), ~0ms cold start |
| CPU limits (Free) | 10ms per invocation |
| CPU limits (Paid) | 30s default, up to 5min per request, 15min for Cron/Queue consumers |
| Duration | No charge or limit |
| Smart Placement | Automatically places Worker near the resources it accesses (databases, APIs) to reduce latency |
| Cron Triggers | Scheduled execution (up to 15min CPU time) |
| Static assets | Served from CDN/cache, free and unlimited requests |

---

## Pattern Options

### Pattern 1: Edge API + Storage Bindings

**What it is:** Worker handles HTTP requests, accesses storage via bindings (KV, R2, D1, etc.)
**When to use:** Standard web APIs, CRUD applications, content delivery.
**When to avoid:** When you need real-time coordination between clients.
**Combines well with:** Smart Placement (auto-optimize latency to DB), Static Assets (serve frontend).

### Pattern 2: Durable Objects for Stateful Services

**What it is:** Worker routes requests to globally-unique Durable Objects that maintain in-memory state and transactional storage.
**When to use:** Chat, collaborative editing, multiplayer games, WebSocket-heavy apps, distributed coordination.
**When to avoid:** Simple CRUD — overkill for read-heavy, stateless workloads.
**Combines well with:** WebSocket Hibernation (scale connections), Alarms (scheduled per-object work).

### Pattern 3: Event-Driven Pipeline

**What it is:** Workers produce messages to Queues, consumer Workers process them asynchronously.
**When to use:** Background job processing, inter-service communication, event buffering before writes.
**When to avoid:** When you need synchronous responses.
**Combines well with:** R2 (write processed results), Analytics Engine (emit metrics).

### Pattern 4: AI at the Edge

**What it is:** Workers AI binding for inference, Vectorize for embeddings, R2 for model artifacts.
**When to use:** RAG workflows, semantic search, AI-powered features.
**When to avoid:** Fine-tuning or training (not supported at edge).
**Combines well with:** D1 or KV (store prompts/config), Queues (async inference).

---

## Bindings Reference

Bindings provide zero-config, secretless access to Cloudflare resources:

| Binding | Purpose |
|---------|---------|
| KV | Key-value storage |
| R2 | Object storage |
| D1 | SQL database |
| Durable Objects | Stateful coordination |
| Queues | Message queuing |
| Hyperdrive | External DB acceleration |
| Workers AI | ML inference |
| Vectorize | Vector database |
| Analytics Engine | Time-series metrics |
| Browser Rendering | Headless browser |
| Service Bindings | Worker-to-Worker calls |
| Rate Limiting | Per-binding rate limits |
| Secrets / Secrets Store | Secret management |

Bindings are declared in `wrangler.jsonc` (or `wrangler.toml`) and accessed via the `env` parameter in the Worker's fetch handler. The underlying credentials are never exposed to code.

---

## Pricing (Paid Plan)

| Resource | Included | Overage |
|----------|----------|---------|
| Workers requests | 10M/month | $0.30/million |
| CPU time | 30M ms/month | $0.02/million ms |
| KV reads | 10M/month | $0.50/million |
| KV writes | 1M/month | $5.00/million |
| KV storage | 1 GB | $0.50/GB-month |
| Static asset requests | Unlimited | Free |
| Base subscription | — | $5/month |

Static asset requests are free and unlimited. Duration (wall-clock time) has no charge or limit.

---

## Anti-Patterns

| Anti-Pattern | Why It Hurts | What to Do Instead |
|-------------|-------------|-------------------|
| Global scope pollution with binding derivatives | Client instances survive binding updates, causing stale secrets | Create new client instances per request |
| Using KV for write-heavy workloads | KV has 1 write/sec per key limit and eventual consistency | Use D1 or Durable Objects for write-heavy patterns |
| Using Durable Objects for simple reads | Overkill, adds routing overhead | Use KV or D1 for stateless read patterns |
| Not using Smart Placement with external DBs | Every request routes to nearest edge, then hops to DB | Enable Smart Placement to colocate with data sources |

---

## Combines With

| Domain | Intersection | Key Consideration |
|--------|-------------|-------------------|
| Frontend (TanStack, React) | Workers serve as the backend/BFF for frontend apps | Use Static Assets for frontend, Workers for API routes |
| Kubernetes | Workers can replace edge-layer services, API gateways | Workers handle edge logic; K8s handles stateful backends |
| Data Platform | Workers can ingest data via Pipelines, query via Hyperdrive | Choose between edge-native storage (D1/KV) vs external DB (Hyperdrive) |
| AI/MCP | Workers AI for inference, Vectorize for embeddings | MCP servers can run as Workers with Durable Objects for state |

---

## Decision Checklist

- [ ] Storage product selected based on consistency and access pattern requirements
- [ ] Smart Placement enabled if accessing non-Cloudflare data sources
- [ ] CPU time limits configured to prevent runaway billing
- [ ] Bindings used instead of REST APIs for Cloudflare resource access
- [ ] Static assets separated from dynamic compute for cost optimization
- [ ] Durable Objects used only when stateful coordination is genuinely needed
