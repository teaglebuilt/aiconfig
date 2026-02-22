# Architecture Analysis Procedures

## Phase 1: Map the Landscape

### 1.1 Project Structure Scan

Run these commands to understand the codebase shape:

```bash
# Overall structure (2 levels deep, ignore noise)
find . -maxdepth 3 -type d \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/.next/*" \
  -not -path "*/build/*" \
  -not -path "*/__pycache__/*" \
  -not -path "*/.venv/*" \
  | head -80

# Count files by type
find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -20

# Identify entry points
find . -maxdepth 2 \( -name "main.*" -o -name "index.*" -o -name "app.*" -o -name "server.*" \) \
  -not -path "*/node_modules/*"

# Find config files (reveals tooling and patterns)
find . -maxdepth 2 \( -name "*.config.*" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" \) \
  -not -path "*/node_modules/*" | head -30
```

### 1.2 Dependency Analysis

**JavaScript/TypeScript:**
```bash
# Root dependencies
cat package.json | jq '.dependencies, .devDependencies' 2>/dev/null

# Monorepo workspace packages
cat package.json | jq '.workspaces' 2>/dev/null
find . -name "package.json" -not -path "*/node_modules/*" -maxdepth 3 \
  -exec jq '{name: .name, deps: (.dependencies // {} | keys)}' {} \;

# Internal import analysis (what imports what)
grep -rn "from ['\"]@" --include="*.ts" --include="*.tsx" \
  -not -path "*/node_modules/*" | sed 's/:.*//' | sort | uniq -c | sort -rn | head -30

# Circular dependency check
npx madge --circular --extensions ts,tsx src/ 2>/dev/null
```

**Python:**
```bash
cat requirements.txt 2>/dev/null || cat pyproject.toml 2>/dev/null
grep -rn "^from\|^import" --include="*.py" -not -path "*/.venv/*" | head -50
```

**Go:**
```bash
cat go.mod
grep -rn "^import" --include="*.go" | head -50
```

### 1.3 Data Layer Identification

```bash
# Database connections / ORM usage
grep -rl "prisma\|typeorm\|sequelize\|knex\|drizzle\|mongoose\|supabase\|firebase" \
  --include="*.ts" --include="*.js" -not -path "*/node_modules/*" | head -20

# Database migrations
find . -type d -name "migrations" -o -name "migrate" | head -10
find . -name "*.sql" -not -path "*/node_modules/*" | head -20

# Schema definitions
find . \( -name "schema.*" -o -name "*.schema.*" -o -name "models.*" -o -name "*.model.*" \) \
  -not -path "*/node_modules/*" | head -20
```

### 1.4 API Surface

```bash
# Route definitions
grep -rn "app\.\(get\|post\|put\|delete\|patch\)\|router\.\|@Get\|@Post\|@Controller\|@app\.route" \
  --include="*.ts" --include="*.js" --include="*.py" \
  -not -path "*/node_modules/*" | head -40

# GraphQL schemas
find . -name "*.graphql" -o -name "*.gql" | head -10
grep -rl "typeDefs\|gql\`\|@Query\|@Mutation" --include="*.ts" --include="*.js" | head -10

# API documentation
find . -name "swagger*" -o -name "openapi*" -o -name "*.api.*" | head -10
```

---

## Phase 2: Identify Patterns in Use

### Pattern Detection Checklist

Look for these indicators:

| Pattern | Indicators |
|---------|-----------|
| **Layered** | `controllers/`, `services/`, `repositories/`, `models/` directories |
| **Hexagonal** | `ports/`, `adapters/`, `domain/`, `infrastructure/` directories |
| **Clean Architecture** | `usecases/`, `entities/`, `interfaces/`, `frameworks/` |
| **Vertical Slice** | Feature folders containing all layers (handler + service + repo + model) |
| **DDD** | `aggregates/`, `valueobjects/`, `domain-events/`, ubiquitous language in code |
| **CQRS** | Separate `commands/` and `queries/` directories or handlers |
| **Event Sourcing** | Event store, event replay, projection builders |
| **Microservices** | Multiple `Dockerfile`s, separate `package.json`s, API gateway config |
| **Modular Monolith** | `modules/` directory with per-module public APIs, internal boundaries |
| **Serverless** | `serverless.yml`, `template.yaml` (SAM), function handlers |

### Consistency Check

After identifying patterns, check if they're applied consistently:

```bash
# Are all features structured the same way?
# Look for structural consistency
for dir in src/features/*/; do
  echo "=== $(basename $dir) ==="
  ls "$dir" 2>/dev/null
done

# Are naming conventions consistent?
find src -type f -name "*.ts" | sed 's/.*\///' | sed 's/\..*//' | sort | uniq -c | sort -rn | head -20
```

---

## Phase 3: Assess Coupling and Cohesion

### Coupling Indicators (High Coupling = Concern)

- **Shared mutable state** — Multiple modules writing to same DB tables
- **Temporal coupling** — Service A must be called before Service B
- **Knowledge coupling** — Module A knows internal details of Module B
- **Import fan-out** — A module importing from many other modules
- **Circular dependencies** — Modules depending on each other bidirectionally
- **Shotgun surgery** — Adding a feature requires changes across many modules

```bash
# Fan-out analysis: which files import the most other files?
grep -c "^import\|^from" --include="*.ts" -r src/ 2>/dev/null | sort -t: -k2 -rn | head -20

# Which modules are imported most? (high fan-in = core dependency)
grep -rh "from ['\"]" --include="*.ts" --include="*.tsx" src/ 2>/dev/null \
  | sed "s/.*from ['\"]//;s/['\"].*//" | sort | uniq -c | sort -rn | head -20
```

### Cohesion Indicators (Low Cohesion = Concern)

- **God classes/modules** — Files doing too many unrelated things
- **Feature envy** — Module A mostly uses data from Module B
- **Divergent change** — One module changes for many different reasons
- **Large modules** — Disproportionately large files or directories

```bash
# Largest files (potential god classes)
find src -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" \
  | xargs wc -l 2>/dev/null | sort -rn | head -20

# Largest directories (potential bloated modules)
du -sh src/*/ 2>/dev/null | sort -rh | head -15
```

---

## Phase 4: Produce Assessment

Structure your findings as:

### Assessment Template

```markdown
# Architecture Assessment: [Project Name]

## Current State

### Dominant Pattern
[Identified pattern(s)] applied [consistently / inconsistently] across [scope].

### Structure Overview
[High-level description of how code is organized]

### Strengths
- [What's working well architecturally]
- [Patterns that are well-applied]
- [Good boundaries that exist]

### Concerns
- [Coupling issues found]
- [Cohesion problems]
- [Inconsistencies in pattern application]
- [Missing boundaries]
- [Technical debt indicators]

### Metrics
- Module count: [N]
- Circular dependencies: [N]
- Largest module: [name] ([N] lines)
- Average fan-out: [N]

## Recommendations (Prioritized)

### P0 — Address Now
[Issues causing active pain or risk]

### P1 — Address Soon
[Issues that will compound if left]

### P2 — Improve Over Time
[Quality improvements, nice-to-haves]

## Suggested Fitness Functions
[Automated checks to prevent regression]
```
