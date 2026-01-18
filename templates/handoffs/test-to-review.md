# Testing → Review Handoff

## Feature: [Feature Name]
## Date: [YYYY-MM-DD]
## Tester: Claude

---

## 1. Test Summary

| Metric | Value |
|--------|-------|
| Test Files Created | [N] |
| Total Test Cases | [N] |
| Passing | [N] |
| Failing | [0] |
| Skipped | [N] |

---

## 2. Test Files

```
apps/web/e2e/
├── [feature].spec.ts           # Main test file
├── [feature]/
│   ├── create.spec.ts          # Create flow tests
│   ├── read.spec.ts            # Read flow tests
│   ├── update.spec.ts          # Update flow tests
│   └── delete.spec.ts          # Delete flow tests
└── pages/
    └── [feature].page.ts       # Page object (if created)
```

---

## 3. Coverage Report

### User Flows
| Flow | Status | Tests |
|------|--------|-------|
| Create [item] | ✅ Covered | 3 tests |
| View [items] | ✅ Covered | 2 tests |
| Edit [item] | ✅ Covered | 2 tests |
| Delete [item] | ✅ Covered | 2 tests |

### Acceptance Criteria
| Criterion | Status | Test |
|-----------|--------|------|
| AC-1: [description] | ✅ Covered | `test-name` |
| AC-2: [description] | ✅ Covered | `test-name` |
| AC-3: [description] | ✅ Covered | `test-name` |

### Edge Cases
| Case | Status | Test |
|------|--------|------|
| Empty state | ✅ Covered | `shows-empty-state` |
| Error handling | ✅ Covered | `handles-api-error` |
| Validation | ✅ Covered | `validates-input` |

---

## 4. Test Execution Results

```
Running 15 tests using 4 workers

  ✓ [feature].spec.ts:10:5 › Happy Path › should create item (2.3s)
  ✓ [feature].spec.ts:25:5 › Happy Path › should view items (1.1s)
  ✓ [feature].spec.ts:40:5 › Happy Path › should edit item (1.8s)
  ✓ [feature].spec.ts:55:5 › Happy Path › should delete item (1.2s)
  ✓ [feature].spec.ts:70:5 › Validation › should show error for empty field (0.8s)
  ... [more tests]

  15 passed (28.4s)
```

---

## 5. Browser Coverage

| Browser | Status |
|---------|--------|
| Chromium | ✅ All Pass |
| Firefox | ✅ All Pass |
| WebKit | ✅ All Pass |

---

## 6. Test Quality Assessment

### Strengths
- [Good coverage of main flows]
- [Proper isolation between tests]
- [Clear assertions]

### Areas for Improvement
- [Could add more edge cases]
- [Performance testing not included]

---

## 7. Flakiness Report

| Test | Flaky | Notes |
|------|-------|-------|
| All tests | ✅ Stable | No flakiness detected |

---

## 8. Bugs Found During Testing

| Bug | Severity | Status | Related Code |
|-----|----------|--------|--------------|
| [None found] | - | - | - |

*Or if bugs were found and fixed:*

| Bug | Severity | Status | Fix |
|-----|----------|--------|-----|
| [Description] | [High/Med/Low] | Fixed | `commit-hash` |

---

## 9. Performance Observations

| Action | Duration | Notes |
|--------|----------|-------|
| Page load | ~500ms | Acceptable |
| List render | ~200ms | Good |
| Form submit | ~300ms | Good |

---

## 10. Test Run Command

```bash
# Run all feature tests
pnpm run test:e2e -- --grep "[feature]"

# Run with UI for debugging
pnpm run test:e2e -- --grep "[feature]" --ui

# Run specific test file
pnpm run test:e2e apps/web/e2e/[feature].spec.ts
```

---

## 11. Handoff Checklist

- [ ] All tests passing
- [ ] No flaky tests
- [ ] Coverage meets requirements
- [ ] Bugs found have been fixed
- [ ] Test code is clean and maintainable

---

## 12. Ready for Review

**Status**: ✅ Ready / ⚠️ Blocked

**Blockers** (if any):
- [blocker description]

**Notes for Reviewer**:
- All acceptance criteria have tests
- Focus review on [area]
- Test data setup in [location]
