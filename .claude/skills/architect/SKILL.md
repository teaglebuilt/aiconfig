# Software Architecture Skill

> Use this skill when making architectural decisions, reviewing system design, analyzing codebase structure, generating architecture diagrams, or evaluating pattern fitness for a project.

## Procedures

This skill provides five core capabilities. Load the relevant resource before executing.

### 1. Analyze Codebase Architecture

When asked to assess or understand an existing codebase's architecture:

1. Read `resources/analysis-procedures.md` for the full analysis playbook
2. Map the project structure, entry points, and dependency graph
3. Identify the dominant patterns in use (layered, hexagonal, vertical slice, etc.)
4. Measure coupling and cohesion indicators
5. Produce a structured assessment with findings and recommendations

**Key commands to run:**
```bash
# Dependency/import analysis (JS/TS)
grep -rn "^import\|^from\|require(" --include="*.ts" --include="*.tsx" --include="*.js" | head -200

# Package dependency graph (monorepo)
cat package.json | jq '.dependencies, .devDependencies'
find . -name "package.json" -not -path "*/node_modules/*" -exec jq '{name: .name, deps: .dependencies}' {} \;

# Module boundary detection
find . -name "index.ts" -o -name "index.js" | grep -v node_modules | sort

# Circular dependency check (if tool available)
npx madge --circular --extensions ts,tsx src/

# Python projects
grep -rn "^import\|^from" --include="*.py" | head -200
cat requirements.txt 2>/dev/null || cat pyproject.toml 2>/dev/null

# Go projects
grep -rn "^import" --include="*.go" | head -200
cat go.mod
```

### 2. Evaluate Architecture Options

When comparing patterns or making a structural decision:

1. Read `resources/patterns.md` for the pattern decision matrices
2. Read `resources/quality-attributes.md` for the scoring framework
3. Identify the top 3-5 quality attributes that matter most for this project
4. Score 2-3 candidate architectures against those attributes
5. Produce a tradeoff analysis using `templates/tradeoff-matrix.md`

### 3. Generate Architecture Decision Record (ADR)

When a decision needs to be documented:

1. Read `templates/adr-template.md`
2. Fill in all sections: context, decision drivers, considered options, decision outcome, consequences
3. Save to the project's ADR directory (typically `docs/adr/` or `.ai/architecture/decisions/`)
4. Name with sequential numbering: `NNNN-short-description.md`

### 4. Generate Architecture Diagrams

When visualizing architecture:

1. Read `resources/diagram-guide.md` for C4, sequence, and deployment diagram patterns
2. Use Mermaid syntax for all diagrams
3. Start at the appropriate C4 level:
   - **Context** — System and its external actors/systems
   - **Container** — High-level technical building blocks
   - **Component** — Internal structure of a container
   - **Code** — Class/module level (rarely needed)
4. Include a legend and brief description with each diagram

### 5. Design New Architecture

When designing from scratch or planning a migration:

1. Read `resources/patterns.md` for pattern options
2. Read `resources/quality-attributes.md` for prioritization
3. Read `resources/analysis-procedures.md` section on migration strategies (if migrating)
4. Load any relevant **domain references** (see below)
5. Follow this sequence:
   - Clarify requirements and constraints (ask if not provided)
   - Identify bounded contexts / domain boundaries
   - Select structural pattern(s)
   - Select communication pattern(s)
   - Select data pattern(s)
   - Define deployment strategy
   - Document with ADR + diagrams
   - Define fitness functions to protect architectural intent

---

## Resource Routing

### Universal Frameworks

| Task | Resource to Read |
|------|-----------------|
| Analyzing existing code | `resources/analysis-procedures.md` |
| Comparing patterns | `resources/patterns.md` |
| Scoring options | `resources/quality-attributes.md` |
| Creating diagrams | `resources/diagram-guide.md` |
| Documenting decisions | `templates/adr-template.md` |
| Comparing options side-by-side | `templates/tradeoff-matrix.md` |

### Domain References

Domain references provide technology-specific architectural knowledge. They live in grouped folders under `context/knowledge/domains/` (relative to the aiconfig root). Load every relevant domain file when the task involves that technology — multiple domains often apply simultaneously.

**To add a new domain reference:** Copy `context/knowledge/domains/_TEMPLATE.md` and follow the structure.

#### `context/knowledge/domains/kubernetes/` — Container Orchestration & Deployment

| File | When to Load |
|------|-------------|
| `kubernetes.md` | Core K8s architecture: cluster topology, namespace strategy, workload patterns, storage, networking |
| `argocd.md` | GitOps deployment: repo strategy, environment promotion, Application/ApplicationSet patterns, sync policies |
| `multicluster.md` | Multi-cluster management: fleet patterns, cross-cluster networking, state synchronization, failover |
| `talos.md` | Talos Linux as K8s OS: immutable infrastructure, API-driven node management, security posture |

#### `context/knowledge/domains/frontend/` — Frontend Architecture

| File | When to Load |
|------|-------------|
| `microfrontends.md` | MFE composition, routing, shared dependencies, inter-MFE communication, deployment |
| `turborepo.md` | Monorepo architecture: package boundaries, dependency direction, caching, task pipelines |

#### `context/knowledge/domains/ai/` — AI Systems Architecture

| File | When to Load |
|------|-------------|
| `mcp.md` | Model Context Protocol: server topology, tool design, transport, agent-to-MCP composition |
| `claude-code.md` | configuring, extending, automating, and enhancing claude code and claude code usage.  |

#### `context/knowledge/domains/devops/` — Infrastructure & Tooling

| File | When to Load |
|------|-------------|
| `nix.md` | Reproducible builds and environments: adoption scope, flakes, caching, container images |

#### `context/knowledge/domains/data/` — Data Architecture

| File | When to Load |
|------|-------------|
| `data-platform.md` | Data architecture paradigm, ingestion, storage, transformation, serving, governance |

#### `context/knowledge/domains/backend/` — Backend Architecture

| File | When to Load |
|------|-------------|
| `kysely.md` | Query builder selection, data access layer architecture, type-safe SQL patterns, Kysely vs ORM decisions |
| `prisma.md` | using prisma ORM, `schema.prisma` file exists, prisma client generation, prisma type safety, prisma client integration |
---

## Domain Loading Rules

1. **Always check `context/knowledge/domains/`** when the task mentions a specific technology
2. **Load multiple domain files** when technologies intersect (e.g., ArgoCD + Kubernetes + Nix for a GitOps deployment decision)
3. **Check the "Combines With" section** at the bottom of each domain file for cross-domain considerations
4. **Universal resources still apply** — domain references supplement the universal frameworks, they don't replace them
5. **If a domain file doesn't exist yet**, use `context/knowledge/domains/_TEMPLATE.md` to reason about the domain's architectural decisions anyway