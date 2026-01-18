# Feature Development Workflow

## Overview

This document outlines the standard process for developing new features from ideation to production.

## Phase 1: Planning

### 1. Define Requirements

Create a Product Requirements Document (PRD):

```markdown
## Feature: [Name]

### Problem Statement
What user problem are we solving?

### Goals
- Primary goal
- Secondary goals

### User Stories
As a [user type], I want [goal] so that [benefit].

### Acceptance Criteria
- [ ] Specific, measurable outcomes
- [ ] Edge cases handled
- [ ] Performance requirements
- [ ] Accessibility requirements

### Non-Goals
What are we explicitly NOT doing?
```

### 2. Technical Design (if complex)

For complex features, create a technical design:

```markdown
## Technical Design: [Feature]

### Architecture
- System components involved
- Data models
- API endpoints

### Key Decisions
- Technology choices
- Trade-offs considered
- Why we chose this approach

### Implementation Plan
1. Step-by-step breakdown
2. Dependencies between steps
3. Potential risks

### Testing Strategy
- Unit test approach
- Integration test approach
- E2E test scenarios
```

### 3. Break Down into Tasks

Create GitHub issues or tasks:

```markdown
## Task: Implement User Authentication API

### Description
Build REST API endpoints for user registration and login.

### Acceptance Criteria
- [ ] POST /api/auth/register endpoint
- [ ] POST /api/auth/login endpoint
- [ ] JWT token generation
- [ ] Password hashing with bcrypt
- [ ] Input validation
- [ ] Error handling
- [ ] Unit tests (>80% coverage)
- [ ] API documentation

### Dependencies
- Database schema (#123)
- User model (#124)

### Estimate
2-3 days
```

## Phase 2: Development

### 1. Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/user-authentication
```

### 2. TDD Approach (Recommended)

```typescript
// 1. Write failing test
describe('AuthService', () => {
  it('should create user with valid data', async () => {
    const service = new AuthService()
    const user = await service.register({
      email: 'test@example.com',
      password: 'SecurePass123!'
    })
    expect(user.id).toBeDefined()
    expect(user.email).toBe('test@example.com')
  })
})

// 2. Implement minimal code to pass
class AuthService {
  async register(data: RegisterInput) {
    // Implementation
  }
}

// 3. Refactor and improve
```

### 3. Implement Feature

Follow coding standards:
- See `context/coding-standards/typescript.md`
- See `context/coding-standards/testing.md`
- Write clean, maintainable code
- Add comments for complex logic
- Keep functions small and focused

### 4. Commit Incrementally

```bash
# Commit logical chunks
git add src/services/auth.service.ts
git commit -m "feat(auth): add user registration service"

git add src/api/auth.routes.ts
git commit -m "feat(auth): add authentication API endpoints"

git add tests/auth.service.test.ts
git commit -m "test(auth): add unit tests for auth service"
```

## Phase 3: Code Quality

### 1. Run Tests

```bash
# Unit tests
npm test

# Integration tests
npm run test:integration

# E2E tests
npm run test:e2e

# Coverage report
npm run test:coverage
```

### 2. Type Checking

```bash
# TypeScript
npm run type-check

# Or in watch mode
npm run type-check:watch
```

### 3. Linting

```bash
# Run linter
npm run lint

# Auto-fix issues
npm run lint:fix
```

### 4. Format Code

```bash
# Prettier
npm run format

# Or format specific files
npx prettier --write src/services/auth.service.ts
```

## Phase 4: Review

### 1. Self-Review

Before creating PR:

- [ ] All tests pass
- [ ] No TypeScript errors
- [ ] No linting errors
- [ ] Code formatted
- [ ] Unnecessary comments removed
- [ ] Console.logs removed
- [ ] Dead code removed
- [ ] Edge cases handled
- [ ] Error messages are helpful
- [ ] Performance is acceptable

### 2. Create Pull Request

```bash
git push -u origin feature/user-authentication
```

Use PR template:

```markdown
## Summary
Implements user authentication with JWT tokens.

## Changes
- Added AuthService with register/login methods
- Created API endpoints for auth
- Implemented JWT token generation
- Added password hashing with bcrypt
- Comprehensive unit tests (95% coverage)

## Test Plan
- [x] Unit tests pass (95% coverage)
- [x] Integration tests pass
- [x] Manually tested in Postman
- [x] Tested error scenarios
- [x] Tested with invalid inputs

## Screenshots
[API response examples]

## Related Issues
Closes #123
Implements user story #45
```

### 3. Address Review Feedback

```bash
# Make requested changes
git add .
git commit -m "fix(auth): address PR feedback

- Improved error messages
- Added input validation
- Fixed edge case in token refresh"

git push
```

## Phase 5: Merge & Deploy

### 1. Merge Requirements

- ✅ All CI checks pass
- ✅ Minimum required approvals (1-2)
- ✅ No merge conflicts
- ✅ Branch up to date with main

### 2. Merge Strategy

```bash
# Option A: Squash and merge (clean history)
# - Combines all commits into one
# - Good for small features

# Option B: Rebase and merge (linear history)
git rebase origin/main
git push --force-with-lease

# Option C: Merge commit (preserves branch history)
# - Good for large features with meaningful commits
```

### 3. Post-Merge

```bash
# Delete feature branch
git checkout main
git pull origin main
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

### 4. Verify in Staging

- [ ] Feature works in staging environment
- [ ] No regressions
- [ ] Performance acceptable
- [ ] Monitoring shows no errors

### 5. Deploy to Production

```bash
# Tag release
git tag -a v1.2.0 -m "Release v1.2.0: User authentication"
git push origin v1.2.0

# Deploy (varies by team)
npm run deploy:production
```

## Phase 6: Monitor

### Post-Deployment Checklist

- [ ] Monitor error rates
- [ ] Check performance metrics
- [ ] Verify analytics tracking
- [ ] Watch for user reports
- [ ] Update documentation

### If Issues Found

```bash
# Option A: Quick hotfix
git checkout -b fix/auth-token-expiry
# Fix and fast-track through review

# Option B: Rollback
git revert abc123
git push origin main
# Or redeploy previous version
```

## Best Practices

### Feature Flags

For large features, use feature flags:

```typescript
// Enable feature incrementally
const isAuthEnabled = featureFlags.get('user-authentication')

if (isAuthEnabled) {
  // New authentication flow
} else {
  // Old flow
}
```

### Database Migrations

```bash
# Create migration
npm run migration:create add_users_table

# Run migration
npm run migration:up

# Rollback if needed
npm run migration:down
```

### Documentation

Update as you go:

- API documentation (OpenAPI/Swagger)
- README if needed
- Architecture diagrams if structure changed
- User-facing docs if applicable

## Common Pitfalls

- ❌ **Scope creep** - Adding "just one more thing"
- ❌ **Skipping tests** - "I'll add them later" (you won't)
- ❌ **Large PRs** - Hard to review, slow to merge
- ❌ **Ignoring edge cases** - Crashes in production
- ❌ **Poor error messages** - Hard to debug
- ❌ **No rollback plan** - Can't undo if something breaks
- ❌ **Incomplete testing** - Only happy path tested

## Shortcuts (When Appropriate)

Sometimes it's OK to move faster:

- **Prototypes** - Skip some tests, focus on validation
- **Internal tools** - Less polish required
- **Spikes** - Throwaway code to explore solutions
- **Urgent hotfixes** - Fix first, improve later (but do improve!)

Always label these clearly:

```typescript
// TODO: This is a prototype - needs proper error handling
// FIXME: Temporary solution for demo
// HACK: Quick fix for production issue #789 - needs refactor
```

## Continuous Improvement

After each feature:

- **Retrospective** - What went well? What didn't?
- **Update docs** - Found a better pattern? Document it
- **Refactor** - Pay down technical debt
- **Share knowledge** - Write blog post, give tech talk
