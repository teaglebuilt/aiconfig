# Review Complete - Feature Ready

## Feature: [Feature Name]
## Date: [YYYY-MM-DD]
## Reviewer: Claude

---

## 1. Review Summary

| Metric | Value |
|--------|-------|
| Files Reviewed | [N] |
| Issues Found | [N] |
| Critical Issues | [N] |
| Major Issues | [N] |
| Minor Issues | [N] |
| All Fixed | ✅ Yes |

---

## 2. Quality Scores

| Category | Score | Notes |
|----------|-------|-------|
| Code Quality | A/B/C/D | [notes] |
| Type Safety | A/B/C/D | [notes] |
| Error Handling | A/B/C/D | [notes] |
| Security | A/B/C/D | [notes] |
| Performance | A/B/C/D | [notes] |
| Accessibility | A/B/C/D | [notes] |
| Maintainability | A/B/C/D | [notes] |

**Overall Grade**: [A/B/C/D]

---

## 3. Issues Found & Fixed

### Critical Issues
*None found* or:
| Issue | File | Fix |
|-------|------|-----|
| [description] | `path:line` | [fix applied] |

### Major Issues
*None found* or:
| Issue | File | Fix |
|-------|------|-----|
| [description] | `path:line` | [fix applied] |

### Minor Issues
*None found* or:
| Issue | File | Fix |
|-------|------|-----|
| [description] | `path:line` | [fix applied] |

---

## 4. Code Quality Assessment

### DRY Compliance
- ✅ No duplicated code blocks
- ✅ Shared logic properly extracted
- ✅ Consistent patterns used

### SOLID Principles
- ✅ Single responsibility maintained
- ✅ Dependencies properly injected
- ✅ Interfaces used appropriately

### Clean Code
- ✅ Meaningful variable names
- ✅ Functions are focused
- ✅ No deep nesting

---

## 5. Type Safety Assessment

- ✅ No `any` types used
- ✅ Return types explicit
- ✅ Zod schemas for validation
- ✅ Type guards where needed

---

## 6. Security Assessment

- ✅ No hardcoded secrets
- ✅ Input validation present
- ✅ RLS policies correct
- ✅ Authorization checks in place
- ✅ No SQL injection vectors
- ✅ No XSS vulnerabilities

---

## 7. Performance Assessment

- ✅ Efficient queries
- ✅ Proper memoization
- ✅ No unnecessary re-renders
- ✅ Lazy loading implemented
- ✅ Bundle size reasonable

---

## 8. Final Verification

```bash
✅ pnpm run lint       # No errors
✅ pnpm run build      # Successful
✅ pnpm run test:e2e   # All passing
```

---

## 9. Files Changed (Final)

### Created
```
[list of new files]
```

### Modified
```
[list of modified files]
```

---

## 10. Commit History

| Hash | Message |
|------|---------|
| `abc1234` | feat([feature]): add database schema |
| `def5678` | feat([feature]): implement services |
| `ghi9012` | feat([feature]): add UI components |
| `jkl3456` | test([feature]): add E2E tests |
| `mno7890` | fix([feature]): address review comments |

---

## 11. Deferred Items

| Item | Reason | Priority |
|------|--------|----------|
| [None] | - | - |

*Or if items deferred:*
| Item | Reason | Priority |
|------|--------|----------|
| [item] | [reason] | [P1/P2/P3] |

---

## 12. Recommendations

### For This Feature
- [Any recommendations for future improvements]

### For Future Features
- [Patterns that worked well]
- [Things to avoid]

---

## 13. Feature Completion Checklist

- [x] Architecture designed
- [x] Tasks planned
- [x] Code implemented
- [x] Tests written
- [x] Tests passing
- [x] Code reviewed
- [x] Issues fixed
- [x] Documentation updated
- [x] Build passing

---

## 14. Ready for Merge

**Status**: ✅ APPROVED

**Merge Instructions**:
```bash
# Create PR if not exists
gh pr create --title "feat: [feature name]" --body "..."

# Or merge if PR exists
gh pr merge [PR_NUMBER] --squash
```

---

## 15. Feature Complete 🎉

The feature is complete and ready for deployment.

**Summary**:
- [Brief summary of what was built]
- [Key capabilities added]
- [Impact on users]

**Next Steps**:
- [ ] Merge PR
- [ ] Deploy to staging
- [ ] QA verification
- [ ] Deploy to production
- [ ] Monitor for issues
