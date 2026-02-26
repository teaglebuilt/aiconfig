# Domain Architecture Reference: Microfrontends

## Overview

Microfrontends extend microservices principles to the frontend — independently developed, tested, and deployed UI modules that compose into a cohesive user experience. Architecturally, they address team autonomy and deployment independence at the UI layer, but introduce composition, routing, and shared state challenges.

---

## Key Architectural Decisions

### Decision 1: Composition Strategy

**Context:** How independently built frontend modules are assembled into a single user experience.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Build-time composition (npm packages) | Shared release cycle is acceptable, strong consistency needs | Not independently deployable — defeats a core MFE benefit |
| Server-side composition (SSI, edge-side includes) | SEO matters, fast initial load, server rendering | Server infrastructure complexity, composition at edge/proxy layer |
| Runtime composition (Module Federation) | Webpack-based stacks, dynamic loading, independent deploys | Runtime dependency resolution, version skew risk, Webpack coupling |
| Client-side composition (iframe) | Maximum isolation, legacy integration, third-party embeds | Poor UX (no shared styles/state), performance overhead, accessibility challenges |
| Client-side composition (web components) | Framework-agnostic, encapsulated custom elements | Web component ecosystem maturity, style encapsulation quirks |
| Client-side composition (single-spa) | Multi-framework support, gradual migration | Orchestration complexity, single-spa as critical dependency |
| Island architecture (Astro-style) | Content-heavy sites with interactive islands | Not for app-like experiences, limited inter-island communication |

### Decision 2: Routing Strategy

**Context:** How URL routing maps to microfrontend modules and who owns it.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Route-based (each MFE owns URL paths) | Clear page-level boundaries, MFEs are full pages | No composition within a page, coarse-grained |
| Component-based (MFEs are components on shared pages) | Fine-grained composition, multiple MFEs per page | Complex orchestration, state sharing between MFEs on same page |
| Hybrid (route-level MFEs with component-level composition) | Mix of page-owned and shared areas (shell + features) | Most flexible but most complex to coordinate |
| Reverse proxy routing (nginx/edge routes to different apps) | Simplest infrastructure, each MFE is a standalone app at a path | Hard transitions between MFEs, duplicate chrome/layout |

### Decision 3: Shared Dependencies

**Context:** How common libraries (React, design system, state management) are handled across MFEs.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Shared via Module Federation (singleton) | All MFEs use same framework, want single instance of React | Version coupling — all MFEs must agree on shared dep version |
| Externals via CDN/import map | Want shared but with explicit version pinning per MFE | Import map management, CDN as dependency |
| Fully independent (each MFE bundles everything) | Maximum independence, different frameworks per MFE | Larger bundles (duplicate React, etc.), inconsistent UX risk |
| Design system as versioned package | Shared UI consistency with independent versioning | MFEs can drift to different design system versions |
| Shared runtime host provides dependencies | Shell app provides React, router, design system to MFEs | Shell becomes critical coupling point |

### Decision 4: Communication Between Microfrontends

**Context:** How MFEs share state and communicate when they coexist on a page.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Custom events (window.dispatchEvent) | Loose coupling, framework-agnostic, simple | No type safety, debugging event chains is hard |
| Shared state store (Redux, Zustand via Module Federation) | Tight coordination needed, same framework | Couples MFEs through shared store, version alignment |
| URL/query params as shared state | Navigation-driven state, bookmarkable | Limited to serializable state, URL pollution |
| Props/attributes from shell to MFE | Shell controls data flow to child MFEs | One-way only, shell becomes coordination bottleneck |
| Message bus (pub/sub) | Decoupled communication, multiple publishers/subscribers | Bus is a hidden dependency, message contract maintenance |
| Backend-driven state (API is source of truth) | MFEs independently fetch what they need | Redundant API calls, eventual consistency between MFEs |

### Decision 5: Deployment and Versioning

**Context:** How MFEs are independently deployed and how versions are managed.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Independent deploy to CDN | True independence, simple infrastructure | Cache invalidation, manifest/import-map updates needed |
| Container per MFE | Infrastructure already Kubernetes-based | Heavier than static serving, overkill for static assets |
| Deploy all MFEs together (coordinated release) | Small team, consistency matters more than independence | Loses independent deployment benefit |
| Canary per MFE | Want progressive rollout per frontend module | Complex routing (which user sees which version), testing matrix |
| Version manifest (import map or config file) | Central control over which MFE versions are active | Manifest is a coordination point, rollback = manifest change |

---

## Pattern Options

### Pattern 1: Shell + Feature MFE Pattern

**What it is:** A thin shell application owns routing, authentication, and global chrome (nav, footer). Feature MFEs are loaded into the shell's content area.
**When to use:** Most microfrontend architectures — this is the most common pattern.
**When to avoid:** When you don't actually need independent deployment (just use a modular monolith).
**Combines well with:** Turborepo (shell + feature packages), Module Federation, single-spa.

### Pattern 2: Vertical Team Ownership

**What it is:** Each team owns a full vertical slice — their MFE, their BFF (backend-for-frontend), their data. End-to-end ownership.
**When to use:** Large org with product teams wanting full autonomy, microservices backend.
**When to avoid:** Small team where vertical slicing creates overhead, shared backend.
**Combines well with:** Microservices, Kubernetes (per-team namespaces), ArgoCD (per-team deployments).

### Pattern 3: Strangler MFE Migration

**What it is:** Incrementally replace a monolithic frontend by wrapping new MFEs around legacy pages. New features are MFEs; old pages migrate over time.
**When to use:** Migrating from a legacy frontend without a big bang rewrite.
**When to avoid:** Greenfield projects (just start with the target architecture).
**Combines well with:** Reverse proxy routing (route new paths to MFE, old paths to legacy), iframe for embedding.

### Pattern 4: Design System as Contract

**What it is:** The shared design system package is the primary integration contract between MFEs. It enforces visual consistency while allowing implementation independence.
**When to use:** Any microfrontend architecture where consistent UX matters.
**When to avoid:** When MFEs are truly independent products with different design languages (rare).
**Combines well with:** Turborepo (design system as a package), Nix (consistent build tooling).

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| Micro-frontend without micro-teams | MFE architecture with one team maintaining everything | All the complexity, none of the team autonomy benefit | Use a modular monolith until team structure justifies MFE |
| Shared state spaghetti | Global Redux store that all MFEs read/write | Tight coupling through shared state, defeats independence | Backend as source of truth, events for cross-MFE communication |
| Framework zoo | React, Vue, Angular, Svelte — one per MFE | Huge bundle sizes, inconsistent UX, hiring/maintenance complexity | Standardize on 1-2 frameworks unless migration requires temporary diversity |
| MFE nano-services | Every button or widget is its own MFE | Composition overhead dominates, performance death by a thousand cuts | MFE boundaries should align with team/domain boundaries, not component boundaries |
| No design system | Each MFE team builds UI from scratch | Inconsistent UX, duplicated effort, Frankenstein UI | Shared design system package as the visual contract |
| Authentication per MFE | Each MFE handles its own auth flow | Inconsistent auth UX, security gaps, token management mess | Shell owns authentication, passes auth context to MFEs |

---

## Fitness Functions

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| Bundle size per MFE | No MFE exceeds size budget | CI bundle analysis (webpack-bundle-analyzer, size-limit) |
| Shared dependency version alignment | No version conflicts on singleton deps | CI check that all MFEs reference same React/shared lib version |
| Design system coverage | MFEs use design system components, not custom UI | Lint for imports from design system vs raw HTML/custom components |
| Independent build | Each MFE builds without other MFEs present | CI builds each MFE in isolation |
| Cross-MFE integration test | Composed application works end-to-end | E2E tests against full composed application |
| Accessibility per MFE | Each MFE meets WCAG standards independently | Automated a11y scanning per MFE (axe-core) |
| Load time budget | Full page with composed MFEs loads within threshold | Lighthouse CI or web-vitals monitoring |

## Decision Checklist

Before finalizing microfrontend architecture:

- [ ] Composition strategy chosen (runtime, build-time, server-side)
- [ ] Routing strategy defined (route-based, component-based, hybrid)
- [ ] Shared dependency strategy documented
- [ ] Inter-MFE communication pattern selected
- [ ] Shell application responsibilities defined
- [ ] Design system package and versioning strategy in place
- [ ] Authentication and authorization owned by shell
- [ ] Deployment pipeline per MFE configured
- [ ] Bundle size budgets set per MFE
- [ ] E2E testing strategy for composed application defined
- [ ] Team structure actually maps to MFE boundaries (otherwise, reconsider MFE)