# Domain Architecture Reference: Turborepo

## Overview

Turborepo is a build system for JavaScript/TypeScript monorepos that provides task orchestration, caching, and dependency-aware execution. Architecturally, it shapes how packages are structured, how build pipelines flow, and how the monorepo scales as packages and teams grow.

---

## Key Architectural Decisions

### Decision 1: Package Boundary Strategy

**Context:** How to slice the monorepo into packages — this is the most consequential decision.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| By technical layer (ui, api, db, utils) | Small project, shared concerns across features | Cross-package changes for every feature, couples unrelated features |
| By domain/feature (auth, billing, dashboard) | DDD alignment, team ownership per domain | Potential duplication of cross-cutting concerns |
| By deployment target (web-app, mobile-app, api-server) | Clear deployable boundaries, CI/CD alignment | Shared logic must live in library packages |
| Hybrid: apps + domain libs + shared libs | Most monorepos at scale | More packages to manage, dependency graph complexity |
| By audience (internal packages, publishable packages) | Open source or shared-library monorepos | Two tiers of quality standards, versioning complexity |

### Decision 2: Dependency Direction and Layering

**Context:** Which packages can depend on which — the dependency graph shapes your architecture.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Strict layers (ui → domain → data → shared) | Want enforced architecture, clear boundaries | Can feel restrictive, cross-layer features need coordination |
| Domain-centric (apps → domain packages → infra packages) | DDD alignment, domain logic is the core | Requires clear domain modeling up front |
| Flat with conventions | Small monorepo, pragmatic team | Relies on discipline, can degrade without enforcement |
| Inverted dependency (domain defines interfaces, infra implements) | Hexagonal/clean architecture in monorepo | More packages (interfaces + implementations), initial overhead |

### Decision 3: Internal Package Build Strategy

**Context:** Whether internal packages are pre-built or consumed as source.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Compiled packages (each package builds to dist/) | Packages are also published externally, clear contracts | Build step for every package, TypeScript project references complexity |
| Source-level imports (transpiled by consuming app) | Internal-only packages, fast iteration, simpler setup | Consuming app's bundler must handle all source, slower app builds |
| Hybrid (shared libs compiled, app-specific source-imported) | Mix of stable shared code and rapidly iterating features | Two patterns to understand, configuration per package |
| Just-in-Time Packages (Turborepo internal packages) | Modern Turborepo with internal package support | Newer pattern, less community precedent |

### Decision 4: Task Pipeline Configuration

**Context:** How tasks (build, test, lint, typecheck) are orchestrated across packages.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Topological (respect dependency order) | Build tasks where output feeds into dependents | Slower for embarrassingly parallel tasks |
| Parallel (no dependency ordering) | Lint, typecheck, test (tasks that don't depend on each other's output) | Incorrect results if tasks actually depend on build output |
| Transit node (tasks in root that delegate) | Orchestration scripts that call per-package tasks | Additional layer of indirection |
| Granular pipelines (separate build:lib, build:app) | Different build strategies for different package types | More pipeline config to maintain |

### Decision 5: Caching Strategy

**Context:** How to maximize cache hit rates for fast CI and local dev.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Local cache only | Solo developer, simple setup | No cache sharing, CI always cold |
| Remote cache (Vercel) | Vercel-hosted, easiest setup | Vendor lock-in, potential cost at scale |
| Remote cache (self-hosted, e.g., Turborepo remote cache API) | Want remote caching without Vercel dependency | Infrastructure to operate, custom implementation |
| Remote cache (Nx Cloud compatible) | Migrating from Nx or want managed cache | Different ecosystem, compatibility nuances |
| Artifact-based caching (CI layer caching + Turborepo) | CI-provider caching + Turborepo local cache | Cache invalidation complexity, CI-specific config |

### Decision 6: Versioning and Publishing

**Context:** If packages need to be published (npm, internal registry), how to manage versions.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| No versioning (internal only) | All packages consumed only within the monorepo | Can't publish, but simplest approach |
| Changesets | Need changelogs, semantic versioning, npm publishing | Requires developer discipline to write changesets |
| Fixed/locked versioning (all packages same version) | Tightly coupled packages released together | Forces release of unchanged packages |
| Independent versioning | Packages evolve at different rates, consumed independently | Complex dependency resolution, diamond dependency risk |

---

## Pattern Options

### Pattern 1: Data Access Layer Pattern

**What it is:** A dedicated internal package that owns all data fetching, mutations, and domain hooks. Apps import hooks from this package — never query databases directly.
**When to use:** Multiple apps consuming the same data (web + mobile + API), want single source of truth for data access.
**When to avoid:** Single app with simple data needs, when it adds indirection without reuse benefit.
**Combines well with:** Domain package strategy, shared types package.

### Pattern 2: Shared Types / Contract Package

**What it is:** A package that exports TypeScript types and interfaces shared across packages. No runtime code — types only.
**When to use:** Multiple packages need the same types (API request/response types, domain entities).
**When to avoid:** Types are only used in one place, over-sharing types couples packages unnecessarily.
**Combines well with:** Data access layer, API packages, code generation from schemas.

### Pattern 3: Feature Package Pattern

**What it is:** Each feature (auth, billing, dashboard) is a self-contained package with its own components, hooks, utils, and tests. Apps compose features.
**When to use:** Team-per-feature ownership, features are independently testable, mix-and-match across apps.
**When to avoid:** Features are deeply intertwined, single app with no reuse needs.
**Combines well with:** Microfrontends (each feature package → MFE), domain-driven design.

### Pattern 4: Config Package Pattern

**What it is:** Shared configuration packages (eslint-config, tsconfig, tailwind-config) that enforce consistency across all packages.
**When to use:** Any monorepo with more than a few packages — consistency matters.
**When to avoid:** Never avoid this — it's almost always the right call.
**Combines well with:** Every other pattern, fitness functions for architectural enforcement.

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| God package | One `shared` or `utils` package everything depends on | Changes to shared break everything, no clear ownership, cache invalidation everywhere | Break into focused packages (shared-types, shared-ui, domain-utils) |
| Circular dependencies | Package A imports from B, B imports from A | Build failures, confusing dependency graph, Turborepo can't topologically sort | Extract shared concern into a third package |
| Leaky abstractions | App directly imports internal files from a package (not its public API) | Coupling to internals, refactoring breaks consumers | Strict barrel exports (index.ts), enforce with linting |
| Build-everything CI | CI builds all packages on every PR regardless of what changed | Slow CI, wasted resources | Use Turborepo's `--filter` with `[origin/main...HEAD]` for affected-only builds |
| Copy-paste packages | Duplicated code across packages instead of extracting shared package | Maintenance burden, divergent behavior | Extract to shared package or accept the duplication is intentional (rule of three) |
| Root-level everything | All source code in root, packages are afterthought | No boundaries, no caching benefit, monolith in monorepo clothing | Move code into proper packages with clear public APIs |

---

## Fitness Functions

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| No circular dependencies | Dependency graph is a DAG | `turbo run build --dry` or `madge --circular`, CI check |
| Package boundary enforcement | No deep imports, only public API | eslint-plugin-boundaries or eslint-plugin-import, import restrictions in tsconfig |
| Dependency direction rules | Domain packages don't import from app packages | Custom lint rule or ArchUnit-style check |
| Cache hit rate monitoring | Builds are actually fast | Track Turborepo cache stats in CI, alert on degradation |
| Package size thresholds | No god packages | Script checking file count or line count per package |
| Unused dependency detection | No phantom dependencies | `depcheck` or `knip` per package in CI |
| Build time budget | Individual package builds stay fast | CI timing per package, alert on regression |

---

## Decision Checklist

Before finalizing Turborepo architecture:

- [ ] Package boundary strategy defined (by domain, by layer, hybrid)
- [ ] Dependency direction rules documented and enforced
- [ ] Internal package build strategy chosen (compiled vs source imports)
- [ ] Task pipeline configured with correct dependency ordering
- [ ] Caching strategy set (local, remote, CI-integration)
- [ ] Shared config packages created (tsconfig, eslint, etc.)
- [ ] CI pipeline uses `--filter` for affected-only execution
- [ ] Public API enforcement in place (barrel exports, linting)
- [ ] New package creation process documented (template or generator)
- [ ] Bundle analysis set up for app packages