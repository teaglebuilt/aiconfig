# Git Conventions

## Branch Naming

### Format

```
<type>/<short-description>
```

### Types

- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates
- `test/` - Adding or updating tests
- `chore/` - Maintenance tasks

### Examples

```
feature/user-authentication
fix/login-validation-error
refactor/api-client-structure
docs/update-readme
test/add-user-service-tests
chore/update-dependencies
```

## Commit Messages

### Format (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, no logic change)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance, dependencies, build config
- `perf` - Performance improvements
- `ci` - CI/CD changes

### Examples

```
feat(auth): add JWT token refresh mechanism

Implement automatic token refresh when access token expires.
Tokens are refreshed 5 minutes before expiration.

Closes #123
```

```
fix(api): handle null response in user endpoint

Previously crashed when user not found. Now returns 404.

Fixes #456
```

```
refactor(utils): simplify date formatting logic

Removed redundant checks and consolidated formatting functions.
No functional changes.
```

### Guidelines

- **Subject line**: 50 characters max, imperative mood ("add" not "added")
- **Body**: Wrap at 72 characters, explain what and why (not how)
- **Footer**: Reference issues/PRs (Closes #123, Fixes #456)
- **Present tense**: "add feature" not "added feature"
- **No period**: At end of subject line

## Workflow

### Feature Development

```bash
# 1. Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/user-profile

# 2. Make changes and commit
git add .
git commit -m "feat(profile): add user profile page"

# 3. Keep branch updated
git fetch origin main
git rebase origin/main

# 4. Push and create PR
git push -u origin feature/user-profile
```

### Bug Fixes

```bash
# 1. Create fix branch
git checkout -b fix/login-error

# 2. Write test that reproduces bug
# 3. Fix the bug
# 4. Commit with reference to issue

git commit -m "fix(auth): resolve login validation error

The email validation regex was too strict.
Now accepts emails with + symbol.

Fixes #789"
```

## Rebasing vs Merging

### Use Rebase For

- **Feature branches** - Keep history clean and linear
- **Updating with main** - `git rebase origin/main`
- **Local commits** - Before pushing

```bash
# Update feature branch with main
git checkout feature/user-profile
git fetch origin main
git rebase origin/main
# Resolve conflicts if any
git push --force-with-lease origin feature/user-profile
```

### Use Merge For

- **Integrating PRs** - Preserves feature branch history
- **Main/production branches** - Never rebase public branches

```bash
# Merge PR (usually done via GitHub/GitLab UI)
git checkout main
git merge --no-ff feature/user-profile
```

## Pull Requests

### PR Title

Follow commit message format:

```
feat(auth): Add social login support
fix(api): Handle edge case in pagination
```

### PR Description Template

```markdown
## Summary
Brief description of changes and motivation.

## Changes
- Added X feature
- Fixed Y bug
- Refactored Z component

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manually tested in browser
- [ ] Tested edge cases

## Screenshots (if UI changes)
[Add screenshots]

## Related Issues
Closes #123
Relates to #456
```

### PR Size

- **Small PRs** - Easier to review, faster to merge
- **Target**: < 400 lines changed
- **If larger**: Break into multiple PRs or explain why it must be large

### Review Process

1. **Self-review** - Review your own PR first
2. **CI passes** - All tests and checks must pass
3. **Request reviewers** - Tag appropriate team members
4. **Address feedback** - Make requested changes
5. **Squash or keep commits** - Depends on team preference

## Git Hygiene

### Before Committing

```bash
# Check what's changed
git status
git diff

# Stage specific files (avoid git add .)
git add src/components/UserProfile.tsx
git add src/api/users.ts

# Review staged changes
git diff --staged
```

### Interactive Rebase

```bash
# Clean up last 3 commits
git rebase -i HEAD~3

# Options:
# pick - keep commit
# reword - change commit message
# squash - combine with previous commit
# fixup - like squash but discard message
# drop - remove commit
```

### Amend Last Commit

```bash
# Fix last commit message
git commit --amend -m "New message"

# Add forgotten files to last commit
git add forgotten-file.ts
git commit --amend --no-edit
```

### Stash Changes

```bash
# Save uncommitted changes
git stash push -m "WIP: working on feature"

# List stashes
git stash list

# Apply and remove from stash
git stash pop

# Apply but keep in stash
git stash apply stash@{0}
```

## Branch Protection

### Main Branch Rules

- ✅ Require PR reviews (min 1-2 approvals)
- ✅ Require CI to pass
- ✅ No direct pushes to main
- ✅ Require branches to be up to date
- ✅ Require signed commits (optional)

## Don'ts

- ❌ Don't commit directly to main
- ❌ Don't force push to shared branches (except with --force-with-lease on feature branches)
- ❌ Don't commit secrets, API keys, or credentials
- ❌ Don't commit large binary files
- ❌ Don't create commits like "fix", "wip", "temp" on main
- ❌ Don't rebase public/shared branches
- ❌ Don't mix unrelated changes in one commit

## Do's

- ✅ Write descriptive commit messages
- ✅ Commit frequently with logical chunks
- ✅ Pull before you push
- ✅ Review your own PRs first
- ✅ Keep commits atomic (one logical change)
- ✅ Test before committing
- ✅ Use .gitignore properly
- ✅ Sign commits (GPG) if team requires
