# Skill Knowledge Centralization

## Status: In Progress

## Overview
Skills that bundle their own technical documentation (domain references, pattern guides, framework docs) create knowledge silos. This story centralizes technology-specific knowledge into `context/knowledge/domains/` so it is reusable across skills, agents, and clients — while skills retain only their procedures, templates, and resource-routing logic.

## User Stories
- As a skill author, I want domain knowledge stored in a shared location so that multiple skills can reference the same technical docs without duplication
- As a developer, I want a single place to find and update technical reference material so that knowledge stays consistent across the system
- As a developer, I want skills to be lightweight procedure definitions that point to shared knowledge rather than bundling their own copies

---

## Phase Tracking

| Phase | Status | Artifacts |
|-------|--------|-----------|
| Plan | ✅ | This story |
| Implement | 🔄 | In progress |
| Test | ⏳ | TBD |
| Review | ⏳ | TBD |

---

## Tasks

### Phase 1: Architect Skill Migration (High Priority)
- [x] TASK-001: Move `domains/` from `.claude/skills/architect/` to `context/knowledge/domains/`
- [ ] TASK-002: Update architect `SKILL.md` domain references to point to `context/knowledge/domains/`
- [ ] TASK-003: Update `_TEMPLATE.md` file placement instructions for the new location

### Phase 2: Documentation Updates (Medium Priority)
- [ ] TASK-004: Update `docs/architecture.md` directory structure to reflect `context/knowledge/domains/`
- [ ] TASK-005: Update `CLAUDE.md` knowledge section to mention domain references

### Phase 3: Audit Other Skills (Low Priority)
- [ ] TASK-006: Audit all skills for embedded technical documentation that should be centralized
- [ ] TASK-007: Move any additional skill-local knowledge files to `context/knowledge/`

---

## Design Decision

### Why `context/knowledge/` and not `docs/`?

| Location | Pros | Cons |
|----------|------|------|
| `context/knowledge/domains/` | Matches existing architecture (static, human-authored reference); already defined as "best practices, patterns"; not auto-loaded into context window — only read on demand by skills | Slightly deeper path |
| `docs/` | Shorter path; conventional for human docs | `docs/` is for project documentation (architecture, PRD, stories), not reusable AI reference material |

**Decision:** `context/knowledge/domains/` — it aligns with the documented `context/` vs `memory/` separation and keeps AI-consumable reference material together.

### Context Window Behavior

Files in `context/` are **not** automatically loaded into the context window. Only `CLAUDE.md` and `README.md` are auto-loaded. Skills explicitly read from `context/knowledge/domains/` on demand using file reads, so there is no context window bloat.

---

## Acceptance Criteria

### Must Have
- [ ] `domains/` lives under `context/knowledge/domains/`
- [ ] Architect skill `SKILL.md` references the new location
- [ ] `_TEMPLATE.md` instructions reflect the new path
- [ ] No broken references in any skill

### Should Have
- [ ] Architecture docs updated
- [ ] Other skills audited for similar patterns

---

## Files Changed

### Moved
```
.claude/skills/architect/domains/ → context/knowledge/domains/
```

### Modified
```
.claude/skills/architect/SKILL.md (update domain paths)
context/knowledge/domains/_TEMPLATE.md (update placement instructions)
docs/architecture.md (update directory tree)
```
