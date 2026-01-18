# Architecture → Planning Handoff

## Feature: [Feature Name]
## Date: [YYYY-MM-DD]
## Architect: Claude

---

## 1. Architecture Summary

### Overview
[2-3 sentence summary of what was designed]

### Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Data Storage | [choice] | [why] |
| API Pattern | [choice] | [why] |
| State Management | [choice] | [why] |
| Component Structure | [choice] | [why] |

---

## 2. Technical Specifications

### Database Schema
```sql
-- Tables to create
CREATE TABLE [table_name] (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- columns
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE [table_name] ENABLE ROW LEVEL SECURITY;
CREATE POLICY "policy_name" ON [table_name] FOR SELECT USING (auth.uid() = user_id);
```

### API Contracts
```typescript
// Endpoints
interface [Feature]API {
  create: (data: CreateInput) => Promise<Result>;
  read: (id: string) => Promise<Item>;
  update: (id: string, data: UpdateInput) => Promise<Result>;
  delete: (id: string) => Promise<void>;
}

// Types
interface CreateInput {
  field1: string;
  field2: number;
}
```

### Component Hierarchy
```
FeatureRoot
├── FeatureList
│   ├── FeatureItem
│   └── FeatureEmptyState
├── FeatureDetail
│   ├── FeatureHeader
│   └── FeatureContent
└── FeatureForm
    ├── FieldGroup
    └── SubmitButton
```

---

## 3. File Structure

### New Files to Create
```
packages/dal/src/
  services/[feature].ts
  hooks/use[Feature].ts
  contracts/[feature].ts

packages/ui/src/
  [Feature]/
    index.tsx
    [Feature].tsx

apps/web/src/pages/
  [feature]/
    index.tsx
    components/
```

### Files to Modify
- `packages/supabase/...` - Type updates
- `apps/web/src/routes.tsx` - New routes

---

## 4. Dependencies & Integration

### External Dependencies
- [ ] [Package name] - [purpose]

### Internal Dependencies
- [ ] Uses `@realview/dal` for data access
- [ ] Uses `@realview/ui` for components

### Integration Points
- [ ] [Existing feature] - [how it connects]

---

## 5. Risks & Considerations

### Technical Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| [risk] | [H/M/L] | [approach] |

### Open Questions
- [ ] [Question for product/design]

---

## 6. Handoff Checklist

- [ ] Architecture document complete: `docs/features/[feature]/architecture.md`
- [ ] Schema migrations defined
- [ ] API contracts typed
- [ ] Component structure mapped
- [ ] Dependencies identified
- [ ] Risks documented

---

## 7. Ready for Planning

**Status**: ✅ Ready / ⚠️ Blocked

**Blockers** (if any):
- [blocker description]

**Notes for Planner**:
- [important context]
- [suggested approach]
