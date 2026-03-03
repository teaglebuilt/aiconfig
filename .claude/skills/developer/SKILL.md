---
name: developer
description: Guides implementation tasks with coding standards and development patterns. Use when implementing features, writing tests, fixing bugs, or reviewing code.
context: fork
agent: developer-agent
model: inherit
---

# Software Development Skill

> Use this skill when implementing features, fixing bugs, writing tests, reviewing code, or following development workflows.

## Procedures

This skill provides four core capabilities. Load the relevant resources before executing.

### 1. Implement a Feature

When building new functionality from a PRD or story:

1. Read the PRD or story document fully
2. Load relevant coding standards (see Knowledge Routing below)
3. Load relevant development knowledge for the tech stack involved
4. Identify existing patterns in the codebase to follow
5. Implement incrementally — smallest working slice first
6. Write tests alongside implementation
7. Self-review against coding standards before declaring done

### 2. Fix a Bug

When diagnosing and fixing a defect:

1. Reproduce the issue — understand exactly what's wrong
2. Read the relevant code paths
3. Load relevant coding standards for the affected area
4. Identify root cause, not just symptoms
5. Write a failing test that demonstrates the bug
6. Fix the code, verify the test passes
7. Check for similar bugs in adjacent code

### 3. Write or Improve Tests

When adding test coverage:

1. Read `context/coding-standards/testing.md` for testing philosophy
2. Identify critical paths lacking coverage
3. Use the AAA pattern (Arrange, Act, Assert)
4. Test behavior, not implementation details
5. Mock at system boundaries only
6. Aim for meaningful coverage, not 100% line coverage

### 4. Review Code

When reviewing code for quality:

1. Load relevant coding standards
2. Check correctness — does it do what it claims?
3. Check edge cases and error handling at boundaries
4. Check consistency with existing patterns
5. Check test coverage on critical paths
6. Provide actionable feedback with context

---

## Knowledge Routing

### Coding Standards (always load for implementation tasks)

| Task | Resource to Read |
|------|-----------------|
| Any TypeScript/JavaScript work | `context/coding-standards/typescript.md` |
| Writing or reviewing tests | `context/coding-standards/testing.md` |

### Workflows

| Task | Resource to Read |
|------|-----------------|
| Git operations, commits, branches | `context/workflows/git-conventions.md` |
| Feature development lifecycle | `context/workflows/feature-development.md` |
| Memory file operations | `context/workflows/data-integrity.md` |

### Development Knowledge

Development knowledge provides framework-specific patterns and best practices. They live in `context/knowledge/development/` (relative to the aiconfig root). Load every relevant file when the task involves that technology.

**To add a new development reference:** Copy `context/knowledge/architecture/_TEMPLATE.md`, adapt for development patterns, and place in the appropriate subdirectory.

#### `context/knowledge/development/nextjs/` — Next.js Development

| File | When to Load |
|------|-------------|
| `nextjs.md` | Any Next.js work: App Router, Server Components, SSR/SSG, API routes, middleware |

#### `context/knowledge/development/react/` — React Development

| File | When to Load |
|------|-------------|
| `react.md` | React components, hooks, state management, context, performance optimization |

---

## Knowledge Loading Rules

1. **Always load coding standards** for the relevant language before implementing
2. **Load development knowledge** when the task involves a specific framework
3. **Load workflow guides** when the task involves git, PRs, or the development lifecycle
4. **Cross-reference architecture knowledge** when implementation decisions have structural implications — load from `context/knowledge/architecture/` as needed
5. **If a knowledge file doesn't exist yet**, note it and proceed with general best practices
