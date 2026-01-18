# Implementation → Testing Handoff

## Feature: [Feature Name]
## Date: [YYYY-MM-DD]
## Developer: Claude

---

## 1. Implementation Summary

| Metric | Value |
|--------|-------|
| Tasks Completed | [N/N] |
| Files Created | [N] |
| Files Modified | [N] |
| Lines of Code | ~[N] |

---

## 2. Files Created

### Packages
```
packages/dal/src/
  services/[feature].ts      # Data operations
  hooks/use[Feature].ts      # React hooks
  contracts/[feature].ts     # TypeScript interfaces
```

### Apps
```
apps/web/src/
  pages/[feature]/
    index.tsx               # Main page
    components/
      [Component].tsx       # Feature components
```

### Other
```
[any other files]
```

---

## 3. Files Modified

| File | Changes |
|------|---------|
| `path/to/file.ts` | [brief description] |
| `path/to/file.ts` | [brief description] |

---

## 4. User Flows to Test

### Primary Flow: [Main Action]
```
1. User navigates to /[feature]
2. User sees [initial state]
3. User clicks [action]
4. User fills [form/inputs]
5. User submits
6. System shows [result]
7. User sees [updated state]
```

### Secondary Flows
1. **[Flow Name]**: [brief description]
2. **[Flow Name]**: [brief description]

---

## 5. Test Scenarios

### Happy Path
| Scenario | Steps | Expected Result |
|----------|-------|-----------------|
| Create [item] | Fill form, submit | Success message, item appears |
| View [items] | Navigate to list | Items displayed |
| Edit [item] | Click edit, modify, save | Updated values shown |
| Delete [item] | Click delete, confirm | Item removed |

### Validation
| Scenario | Input | Expected Result |
|----------|-------|-----------------|
| Empty required field | Leave blank | Error message |
| Invalid format | Wrong format | Validation error |
| Duplicate | Existing value | Conflict error |

### Error Handling
| Scenario | Trigger | Expected Result |
|----------|---------|-----------------|
| Network failure | Disconnect | Retry option |
| Server error | Force 500 | Error message |
| Unauthorized | Wrong role | Access denied |

### Edge Cases
| Scenario | Condition | Expected Result |
|----------|-----------|-----------------|
| Empty state | No data | Empty state UI |
| Large dataset | 100+ items | Pagination works |
| Concurrent edit | Two users | Conflict handling |

---

## 6. Test Data Requirements

### User Roles Needed
- [ ] Regular user
- [ ] Business owner
- [ ] Admin (if applicable)

### Pre-existing Data
- [ ] [Data needed for tests]

### Data to Create
- [ ] [Data created during tests]

---

## 7. API Endpoints to Test

| Method | Endpoint | Test Cases |
|--------|----------|------------|
| GET | `/api/[feature]` | List, filter, paginate |
| POST | `/api/[feature]` | Create, validate |
| PUT | `/api/[feature]/:id` | Update, not found |
| DELETE | `/api/[feature]/:id` | Delete, not found |

---

## 8. Components to Test

| Component | Interactions | States |
|-----------|--------------|--------|
| `[FeatureList]` | Click item, scroll | Loading, empty, populated |
| `[FeatureForm]` | Fill, submit, reset | Valid, invalid, submitting |
| `[FeatureItem]` | Click, hover | Default, selected, disabled |

---

## 9. Acceptance Criteria Coverage

From task files:

- [ ] AC-1: [criterion] → Test: [test name]
- [ ] AC-2: [criterion] → Test: [test name]
- [ ] AC-3: [criterion] → Test: [test name]

---

## 10. Known Issues / Limitations

| Issue | Impact | Notes |
|-------|--------|-------|
| [issue] | [impact] | [workaround if any] |

---

## 11. Build Status

```bash
✅ pnpm run lint      # Passed
✅ pnpm run build     # Passed
✅ pnpm run type-check # Passed (if separate)
```

---

## 12. Handoff Checklist

- [ ] All tasks marked complete
- [ ] Code compiles without errors
- [ ] Linting passes
- [ ] Manual smoke test done
- [ ] User flows documented
- [ ] Test scenarios defined

---

## 13. Ready for Testing

**Status**: ✅ Ready / ⚠️ Blocked

**Blockers** (if any):
- [blocker description]

**Notes for Tester**:
- Focus on [priority area]
- Known limitation: [limitation]
- Test data location: [path or instructions]
