# Domain Architecture Reference: Kysely

> **Implementation agent available:** For hands-on query building, type error resolution, and Kysely implementation work, hand off to the `kysely-query-architect` agent.

## Overview

Kysely is a type-safe TypeScript SQL query builder that provides compile-time type checking for SQL queries without an ORM abstraction layer. Architecturally, it occupies a specific niche between raw SQL and full ORMs — giving you SQL control with TypeScript safety. The key architectural decision is whether this tradeoff fits your project's needs.

---

## Key Architectural Decisions

### Decision 1: Query Builder vs ORM vs Raw SQL

**Context:** The foundational choice — how does your application talk to the database?

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Kysely (type-safe query builder) | Team knows SQL, wants type safety without ORM abstraction, needs full SQL control | No built-in relations, no auto-migrations, you write SQL (in TypeScript) |
| Prisma (ORM + query engine) | Want schema-first, auto-generated types, relation loading, migrations | Prisma Client overhead, less SQL control, own query engine (not raw driver) |
| Drizzle (type-safe ORM-like) | Want Kysely-like SQL control with more ORM features (relations, schema-in-code) | Newer ecosystem, API still evolving, different mental model than Kysely |
| TypeORM / MikroORM (traditional ORM) | Want Active Record or Data Mapper patterns, entity decorators | Runtime overhead, type safety gaps, complex eager/lazy loading |
| Raw SQL (pg, mysql2, better-sqlite3) | Maximum control, performance-critical, simple queries | No type safety, SQL injection risk if not careful, manual type definitions |
| Knex (query builder, no types) | Legacy projects, JavaScript (not TypeScript) | Weak type safety, Kysely is essentially "typed Knex" |

### Decision 2: Where Kysely Fits in Your Architecture

**Context:** Kysely is a data access tool — where in your layer stack does it live?

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Repository pattern (Kysely inside repositories) | Want to isolate DB logic, testable with dependency injection | Additional abstraction layer, more files |
| DAL package (Kysely in shared data access layer) | Monorepo, multiple apps consuming same data | DAL becomes a dependency, versioning and API design matter |
| Direct in service layer | Small app, few queries, minimal abstraction needed | DB logic mixed with business logic, harder to test in isolation |
| Query functions (exported standalone functions) | Functional style, composable, tree-shakeable | No class-based organization, can become a bag of functions |
| Alongside Prisma (Kysely for complex queries, Prisma for CRUD) | Already using Prisma but hitting its query limitations | Two query tools to maintain, type alignment between them |

### Decision 3: Type Generation Strategy

**Context:** How Kysely gets its TypeScript types for your database schema.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| kysely-codegen (introspect DB → types) | Database is source of truth, schema managed externally | Requires running DB for type gen, CI pipeline consideration |
| prisma-kysely (Prisma schema → Kysely types) | Already using Prisma for schema/migrations | Dependency on Prisma schema, extra build step |
| Hand-written types | Small schema, full control, no external tooling | Manual maintenance, drift risk as schema evolves |
| kanel (PostgreSQL → types) | PostgreSQL-specific, want detailed type customization | PostgreSQL only, another codegen tool |
| Schema-from-migrations (derive from migration files) | Migrations are source of truth, want types to match | Less common pattern, tooling maturity varies |

### Decision 4: Migration Strategy

**Context:** How database schema changes are managed when using Kysely.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Kysely's built-in migrator | Want everything in Kysely, simple migration needs | Basic feature set, no down migrations by default |
| kysely-ctl | Want Knex-like CLI for migrations and seeds | Additional dependency, but good DX |
| Prisma Migrate + prisma-kysely | Using Prisma for schema management, Kysely for queries | Two tools, but each does what it's best at |
| Atlas (external schema management) | Want declarative schema diffing, multi-dialect | Separate tool, Go-based, learning curve |
| dbmate / golang-migrate | Language-agnostic SQL migration files | Plain SQL files, no TypeScript integration |
| Manual SQL scripts | Full control, simple requirements | No automation, ordering and tracking is manual |

### Decision 5: Connection and Pooling Architecture

**Context:** How Kysely connects to the database, especially in serverless or multi-tenant environments.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Single Kysely instance (shared pool) | Traditional server, single database | Simple, but pool exhaustion risk under load |
| Kysely instance per request (serverless) | Serverless functions, short-lived connections | Connection overhead per invocation, use connection pooler (PgBouncer, Supabase pooler) |
| Multi-tenant (schema per tenant) | SaaS, tenant isolation at schema level | Dynamic Kysely instances or schema switching, connection pool per tenant |
| Multi-tenant (row-level security) | SaaS, shared schema with RLS | Single Kysely instance, RLS policy management |
| Read/write splitting | High-read workloads, read replicas | Multiple Kysely instances, routing logic |

### Decision 6: Dialect and Platform

**Context:** Which database and hosting platform Kysely targets.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| PostgreSQL (pg driver) | Most cases — rich features, JSONB, arrays, full-text search | Heavier than SQLite, hosting cost |
| PostgreSQL (Neon serverless driver) | Serverless, edge functions, Neon-hosted | Neon-specific driver, HTTP-based connection |
| PostgreSQL (Supabase) | Supabase platform, want Kysely alongside Supabase client | Two data access paths, auth token handling |
| SQLite (better-sqlite3) | Local-first, embedded, edge, Electron | Limited SQL features, no concurrent writes |
| MySQL/MariaDB (mysql2) | Existing MySQL infrastructure | MySQL-specific syntax differences |
| PlanetScale (MySQL-compatible) | Serverless MySQL, branching workflows | PlanetScale-specific driver, no foreign keys by default |
| Turso (libSQL) | Edge SQLite, distributed reads | Newer platform, libSQL dialect |

---

## Pattern Options

### Pattern 1: Repository + Kysely

**What it is:** Each domain entity gets a repository class/module that encapsulates all Kysely queries for that entity. Business logic never touches Kysely directly.
**When to use:** Medium-large applications, team wants testability and separation of concerns.
**When to avoid:** Small apps where the repository layer is just pass-through boilerplate.
**Combines well with:** Turborepo DAL package pattern, dependency injection, monorepo architecture.

### Pattern 2: Composable Query Helpers

**What it is:** Reusable functions that accept and return Kysely query builders, composing filters, pagination, sorting, and common patterns as building blocks.
**When to use:** Many queries share similar patterns (pagination, soft deletes, tenant filtering, audit fields).
**When to avoid:** Queries are all unique with no shared patterns.
**Combines well with:** Functional architecture, tree-shaking, library packages in monorepo.

### Pattern 3: Kysely + Prisma Hybrid

**What it is:** Prisma handles schema management, migrations, and simple CRUD. Kysely handles complex analytical queries, CTEs, window functions, and anything Prisma can't express. Types shared via prisma-kysely.
**When to use:** Already invested in Prisma but hitting its query limitations.
**When to avoid:** Greenfield where you can pick one tool, or when Prisma's query API covers all your needs.
**Combines well with:** Existing Prisma projects, gradual adoption of Kysely for specific query needs.

### Pattern 4: Type-Safe DAL Package

**What it is:** A dedicated monorepo package that owns all database access, exporting typed query functions and hooks. Kysely is an implementation detail — consumers only see typed inputs/outputs.
**When to use:** Monorepo with multiple apps (web, mobile, API) consuming the same data.
**When to avoid:** Single app where the package boundary adds unnecessary indirection.
**Combines well with:** Turborepo package patterns, your existing DAL architecture approach.

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| `any` everywhere | Casting to `any` to silence type errors | Defeats Kysely's entire value proposition | Fix types properly — use the `kysely-query-architect` agent for help |
| Leaking Kysely types to consumers | API returns `Selectable<UserTable>` instead of a domain `User` type | Couples consumers to DB schema, Kysely becomes a viral dependency | Map to domain types at the repository/DAL boundary |
| God query functions | Single function building 15-join queries dynamically | Type explosion ("excessively deep"), unmaintainable | Break into CTEs, composable helpers, or multiple focused queries |
| Skipping codegen | Hand-maintaining types for a 50-table schema | Types drift from actual schema, runtime errors | Use kysely-codegen or prisma-kysely for type generation |
| Raw SQL for everything | Using `sql` template tag for queries Kysely can express natively | Loses type safety, back to string SQL | Only use `sql` for genuinely unsupported features |
| No transaction boundaries | Individual queries without transactions for multi-step operations | Data inconsistency, partial writes | Use `db.transaction().execute()` for atomic operations |

---

## Fitness Functions

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| No `any` in data access layer | Type safety maintained | ESLint `@typescript-eslint/no-explicit-any` in DAL package |
| Generated types match schema | Types aren't stale | Run kysely-codegen in CI, fail if output differs from committed types |
| No Kysely imports outside DAL | Kysely is an implementation detail | eslint-plugin-boundaries or import restriction rules |
| Query execution time budget | No slow queries in critical paths | Integration tests with query timing assertions |
| Transaction coverage | Multi-step operations use transactions | Code review checklist, custom lint rule for adjacent query calls |
| Migration CI check | Migrations apply cleanly | Run migrations against fresh DB in CI |

---

## Decision Checklist

Before finalizing Kysely architecture:

- [ ] Query builder vs ORM decision made with team alignment
- [ ] Type generation strategy chosen and integrated in build pipeline
- [ ] Migration strategy defined (Kysely-native, Prisma, external tool)
- [ ] Data access layer boundary defined (repository, DAL package, or direct)
- [ ] Connection pooling strategy appropriate for deployment model (server vs serverless)
- [ ] Dialect and driver selected, matching hosting platform
- [ ] Domain type mapping in place (DB types don't leak to consumers)
- [ ] Transaction patterns documented for multi-step operations
- [ ] CI checks for type generation staleness
- [ ] Team familiar with Kysely's SQL-first mental model (vs ORM thinking)