# Claude Code Configuration

Welcome to the AIConfig shared context system. This configuration provides consistent coding preferences and workflows across AI coding assistants.

## Overview

This repository serves as a **portable AI configuration** ("aiconfig") that works across multiple AI coding tools:
- **Claude Code** (you are here)
- **Cursor** (via `.cursor/rules`)
- **Other AI assistants** (via shared context files)

## Shared Context System

All context is stored in the `context/` directory and organized by category:

### 📝 Coding Standards (`context/coding-standards/`)
- **TypeScript** - Type safety, naming, patterns, React best practices
- **Testing** - Testing philosophy, AAA pattern, mocking, coverage

### 🔄 Workflows (`context/workflows/`)
- **Git Conventions** - Commit messages, branch naming, PR process
- **Feature Development** - Planning, implementation, review, deployment

### 💬 Prompts (`context/prompts/`)
- **Code Review** - Security, performance, architecture review templates
- **Debugging** - Systematic debugging approaches and prompt patterns

### 🧠 Knowledge (`context/knowledge/`)
- **AI Coding Best Practices** - How to work effectively with AI coding assistants

## Core Principles

### Type Safety
- Use TypeScript with `strict: true`
- Avoid `any` - use `unknown` if type is truly unknown
- Prefer type inference over explicit types when obvious
- Use discriminated unions for complex state

### Code Quality
- **Functional patterns** - Prefer immutability, pure functions
- **Error handling** - Result types for expected errors, exceptions for unexpected
- **Testing** - Write tests, aim for 80% coverage, test behavior not implementation
- **Clean code** - Small functions, descriptive names, minimal comments

### Git Workflow
- **Conventional commits** - `type(scope): subject`
- **Descriptive branches** - `type/short-description`
- **Atomic commits** - One logical change per commit
- **Self-review** - Review your own code before requesting review

### Development Process
When implementing features:
1. Break large tasks into smaller steps
2. Write tests as you go (TDD when appropriate)
3. Commit incrementally with logical chunks
4. Self-review before requesting human review

## Skills Available

### `/generate-prd`
Generate a Product Requirements Document (PRD) for a new feature. Creates structured documentation with user stories, acceptance criteria, and technical considerations.

**Usage**: `/generate-prd` then answer clarifying questions

### `/generate-prd-to-json`
Convert PRDs to `prd.json` format for autonomous agent systems. Breaks features into right-sized stories that fit in one context window.

**Usage**: `/generate-prd-to-json` with an existing PRD

## Communication Preferences

- **Be specific** - Provide clear requirements and context
- **Ask questions** - Clarify ambiguities before implementing
- **Explain reasoning** - Share why, not just what
- **Iterate** - Start with working solution, then refine
- **Think critically** - Suggest improvements, catch issues early

## What to Avoid

- ❌ Don't add features beyond what's requested
- ❌ Don't over-engineer simple solutions
- ❌ Don't add comments that restate the code
- ❌ Don't create abstractions for one-time use
- ❌ Don't disable TypeScript errors without good reason
- ❌ Don't commit untested code

## Using This Config in Projects

### Option 1: Symlink
```bash
cd ~/my-project
ln -s ~/aiconfig/context .aiconfig
ln -s ~/aiconfig/CLAUDE.md CLAUDE.md
```

### Option 2: Git Submodule
```bash
cd ~/my-project
git submodule add <repo-url> .aiconfig
ln -s .aiconfig/CLAUDE.md CLAUDE.md
```

### Option 3: Direct Clone
```bash
cd ~/my-project
git clone <repo-url> .aiconfig
# Add .aiconfig to .gitignore if preferred
```

## Accessing Context

The context files are available at:
- `context/coding-standards/typescript.md`
- `context/coding-standards/testing.md`
- `context/workflows/git-conventions.md`
- `context/workflows/feature-development.md`
- `context/prompts/code-review.md`
- `context/prompts/debugging.md`
- `context/knowledge/ai-coding-best-practices.md`

Reference these files when you need detailed guidelines for specific areas.

## Design Philosophy

This configuration embodies the philosophy of **vibecoding** - a smooth, efficient development flow where:
- Context is always available
- Standards are consistent
- Workflows are clear
- AI assistants are aligned
- Quality is maintained
- Speed is preserved

You're not just a code generator - you're a coding partner. Think critically, suggest improvements, and help build quality software.

---

For architecture details, see `DESIGN.md`