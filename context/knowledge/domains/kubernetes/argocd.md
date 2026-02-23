# Domain Architecture Reference: ArgoCD

## Overview

ArgoCD is a declarative GitOps continuous delivery tool for Kubernetes. Architecturally, it's the reconciliation layer that ensures cluster state matches a desired state declared in Git. It fundamentally shapes how deployments, promotions, and environment management are structured.

---

## Key Architectural Decisions

### Decision 1: ArgoCD Topology

**Context:** How many ArgoCD instances and what do they manage?

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Single ArgoCD managing all clusters | Small org, few clusters, centralized ops | Single point of failure, RBAC complexity grows, blast radius |
| ArgoCD per cluster (self-managing) | Strong isolation needs, independent team ops | Duplicated config, harder to get global view |
| Hub ArgoCD managing spoke clusters | Platform team model, centralized governance | Hub is critical path, network connectivity requirements |
| ArgoCD per environment tier | Separate prod ArgoCD from non-prod | More instances to manage, but prod isolation |

### Decision 2: Repository Strategy

**Context:** How to organize the Git repos ArgoCD watches.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| App repo + separate config repo | Clear separation of app code from deployment config | Two repos to maintain per app, sync between them |
| Monorepo for all config | Atomic changes across services, single source of truth | Large repo, broad blast radius per commit, RBAC harder at file level |
| Config alongside app code | Small team, simple deployments, co-located changes | Mixing concerns, harder to manage environment promotion |
| Config repo per team/domain | Team autonomy with bounded ownership | Cross-team changes require multi-repo coordination |

### Decision 3: Environment Promotion Strategy

**Context:** How changes move from dev → staging → production.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Branch-per-environment | Simple mental model, familiar Git workflow | Branch drift, merge conflicts, hard to audit what's where |
| Directory-per-environment with Kustomize overlays | Clean separation, DRY base + overlays | Directory structure can get complex, Kustomize learning curve |
| Git tag / commit SHA promotion | Immutable references, audit trail | Requires tooling to automate promotion, less intuitive |
| Pull request promotion (PR to env branch/dir) | Approval gates, review process per promotion | Slower, more ceremony, but safer for prod |
| ApplicationSet with progressive sync | Automated multi-cluster rollout | Complex to configure, need good rollback strategy |

### Decision 4: Application Definition Strategy

**Context:** How to define what ArgoCD manages — individual Applications vs. automation.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Manual Application CRDs | Few applications, hand-curated | Doesn't scale, manual toil for each new service |
| App of Apps pattern | Hierarchical management, bootstrap pattern | Nested dependencies can be confusing, ordering issues |
| ApplicationSet (generators) | Many similar apps, convention-based | Less flexibility per app, generator logic can be opaque |
| ApplicationSet + Git generator | Monorepo or multi-repo auto-discovery | Directory structure becomes API contract, accidental app creation risk |
| ApplicationSet + Matrix generator | Multi-cluster × multi-app deployment matrix | Combinatorial complexity, harder to reason about |

### Decision 5: Helm vs Kustomize vs Plain Manifests

**Context:** What templating/overlay strategy ArgoCD consumes.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Kustomize overlays | Environment variations on a common base, simple diffs | Limited logic capabilities, patching syntax learning curve |
| Helm charts | Reusable packages, complex parameterization, community charts | Template debugging is painful, values.yaml can become sprawling |
| Plain YAML manifests | Very simple deployments, full transparency | No DRY, duplication across environments |
| Helm + Kustomize post-rendering | Helm for packaging, Kustomize for env-specific patches | Two systems to understand, debugging through both layers |
| Jsonnet / CUE | Programmable config, type checking | Niche tooling, smaller community, steeper learning curve |

### Decision 6: Sync and Health Strategy

**Context:** How ArgoCD handles sync behavior and determines application health.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Auto-sync enabled | Non-production environments, fast feedback loops | Unintended changes deploy automatically, less control |
| Manual sync only | Production, change-controlled environments | Slower, requires human action, but safer |
| Auto-sync with self-heal | Want to prevent manual kubectl drift | Overrides intentional manual changes (hotfixes become hard) |
| Sync windows | Restrict deployments to maintenance windows | Adds scheduling complexity, blocks urgent deploys outside windows |
| Custom health checks (Lua) | Non-standard resources or complex readiness criteria | Lua scripts to maintain, testing health checks is awkward |

---

## Pattern Options

### Pattern 1: App of Apps Bootstrap

**What it is:** A root Application that manages child Applications. The root is the only thing manually applied; everything else is GitOps-managed.
**When to use:** Cluster bootstrapping, managing a known set of infrastructure and platform apps.
**When to avoid:** Large numbers of dynamic applications (use ApplicationSet instead), when you need fine-grained sync ordering.
**Combines well with:** Kubernetes cluster bootstrap, Nix for tooling reproducibility.

### Pattern 2: ApplicationSet with Convention-Based Discovery

**What it is:** ApplicationSet generators auto-discover apps based on directory structure or labels. Adding a new service means adding a directory — ArgoCD picks it up automatically.
**When to use:** Monorepos or standardized multi-repo setups where apps follow conventions.
**When to avoid:** When apps have wildly different deployment needs, when convention enforcement is weak.
**Combines well with:** Turborepo (directory-per-package maps to ApplicationSet git generator), microfrontends.

### Pattern 3: Progressive Delivery with Argo Rollouts

**What it is:** Replace Kubernetes Deployments with Rollout resources for canary, blue-green, or analysis-driven deployments.
**When to use:** Production services where you want automated canary analysis, gradual traffic shifting.
**When to avoid:** Simple or internal services where rolling updates are sufficient.
**Combines well with:** Service mesh (traffic shifting), observability (analysis metrics).

### Pattern 4: Multi-Cluster Fleet Management

**What it is:** Central ArgoCD managing applications across many clusters, using ApplicationSets with cluster generators.
**When to use:** Platform team managing standardized deployments across fleet of clusters.
**When to avoid:** Heterogeneous clusters with very different workloads, when network connectivity is unreliable.
**Combines well with:** Kubernetes cluster topology decisions, hub-and-spoke architecture.

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| Click-ops ArgoCD | Creating Applications through the UI, not Git | Defeats GitOps, state not in repo, unreproducible | Define all Applications/ApplicationSets as manifests in Git |
| Branch-per-env drift | Dev, staging, prod branches diverge significantly | What you test isn't what you deploy, merge conflicts | Directory-per-env with Kustomize or Helm values overlays |
| Secret sprawl in Git | Secrets committed (even encrypted) alongside every app | Key management nightmare, rotation complexity | External Secrets Operator or Sealed Secrets with centralized vault |
| Sync loop storms | Auto-sync + mutating webhooks or controllers fighting ArgoCD | Constant reconciliation, resource churn, API server load | Ignore fields modified by other controllers, use ignoreDifferences |
| Mega Application | One ArgoCD Application managing entire cluster | Slow sync, blast radius is everything, can't partially rollback | One Application per service/component, use App of Apps or ApplicationSet |
| No sync windows on prod | Auto-sync to production with no guardrails | Unintended prod deployments, no change control | Manual sync or sync windows for production |

---

## Fitness Functions

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| No Applications defined via UI | All config is in Git | Audit ArgoCD Application source annotations, alert on manual creates |
| Sync status monitoring | Cluster matches Git | ArgoCD metrics + alerting on OutOfSync > threshold |
| No auto-sync on production | Prod requires manual approval | Policy check on Application spec for prod-targeted apps |
| ApplicationSet coverage | All services have ArgoCD Applications | Compare deployed apps against expected list from service registry |
| Drift detection alerts | Someone kubectl-edited a managed resource | ArgoCD diff detection + alert on self-heal events |
| Health check coverage | Custom resources have health checks defined | Audit ArgoCD resource customizations for CRDs in use |

---

## Decision Checklist

Before finalizing ArgoCD architecture:

- [ ] ArgoCD topology chosen (single, per-cluster, hub-spoke)
- [ ] Repository strategy defined (monorepo, config-per-app, separate config repo)
- [ ] Environment promotion strategy documented
- [ ] Application definition approach chosen (manual, App of Apps, ApplicationSet)
- [ ] Templating strategy decided (Helm, Kustomize, plain YAML)
- [ ] Sync policy defined per environment (auto vs manual, self-heal, sync windows)
- [ ] Secret management approach integrated
- [ ] RBAC configured (who can sync what, project isolation)
- [ ] Notification strategy set up (Slack, webhook on sync failures)
- [ ] Disaster recovery plan for ArgoCD itself (backup, rebuild)