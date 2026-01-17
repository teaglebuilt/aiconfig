# AIConfig Shared Context Foundation Design

## Overview

This repository serves as a **portable AI configuration system** for "vibecoding" across multiple AI coding assistants (Claude Code, Cursor, etc.). It provides a single source of truth for coding preferences, workflows, and knowledge that works seamlessly across different tools.

## Design Philosophy

### Core Principles

1. **Single Source of Truth**: All context lives in the `context/` directory as markdown files
2. **Tool Adapters**: Each AI tool has configuration that references shared context
3. **Version Controlled**: Track evolution of AI coding preferences over time
4. **Portable**: Clone once, use in any project via symlinks or includes
5. **Composable**: Pick and choose which context to load per project
6. **Smart Scoping**: Context automatically applies based on file patterns and directory structure

## Architecture

```
aiconfig/
├── context/                          # SOURCE OF TRUTH - Shared context
│   ├── coding-standards/            # Language-specific preferences
│   │   ├── typescript.md
│   │   ├── python.md
│   │   ├── testing.md
│   │   └── architecture.md
│   ├── workflows/                   # Development processes
│   │   ├── git-conventions.md
│   │   ├── pr-process.md
│   │   └── feature-development.md
│   ├── prompts/                     # Reusable prompt templates
│   │   ├── code-review.md
│   │   ├── refactoring.md
│   │   └── debugging.md
│   └── knowledge/                   # Project-agnostic knowledge
│       ├── domain-concepts.md
│       └── tech-stack.md
│
├── .cursor/rules/                   # CURSOR ADAPTER
│   ├── typescript-standards.mdc     # References context/coding-standards/typescript.md
│   ├── python-standards.mdc         # References context/coding-standards/python.md
│   ├── git-workflow.mdc             # References context/workflows/git-conventions.md
│   └── core-context.mdc             # Always-on foundational context
│
├── .claude/                         # CLAUDE CODE ADAPTER
│   ├── skills/                      # Custom Claude Code skills
│   │   ├── generate-prd/
│   │   └── generate-prd-to-json/
│   └── session-hooks/               # Session initialization
│
├── CLAUDE.md                        # Main Claude Code instructions
├── DESIGN.md                        # This file
└── README.md                        # Usage documentation
```

## How It Works

### Cursor Integration

Cursor uses **Project Rules** stored in `.cursor/rules/*.mdc` files. Each rule:

- Has **frontmatter metadata** (YAML) controlling behavior
- Contains **markdown content** with instructions
- Can be **scoped to file patterns** using `globs`
- Can be **always active** using `alwaysApply: true`
- **Automatically attaches** when working on matching files

**Frontmatter Options:**
```yaml
---
description: "Brief description of what this rule provides"
globs: "**/*.ts,**/*.tsx"           # Glob patterns (optional)
alwaysApply: false                   # Always include (optional)
---
```

**Key Behaviors:**
- When `alwaysApply: true`, the rule is always included (globs ignored)
- When using `globs`, rule auto-attaches when matching files are in context
- Cursor's agent decides relevance even for always-applied rules
- Nested `.cursor/rules` in subdirectories scope rules to those directories

### Claude Code Integration

Claude Code uses:
- **CLAUDE.md** in repository root for main instructions
- **.claude/skills/** for custom slash commands
- **Imports** of shared context files from `context/` directory

### Shared Context Strategy

The `context/` directory contains **canonical knowledge** in well-structured markdown:

1. **coding-standards/**: Language-specific preferences, testing approaches, architectural patterns
2. **workflows/**: Git conventions, PR processes, feature development flows
3. **prompts/**: Reusable prompt templates for common tasks
4. **knowledge/**: Domain knowledge, tech stack decisions, architectural records

**Tool adapters reference these files** rather than duplicating content:

```markdown
# In .cursor/rules/typescript-standards.mdc
---
description: "TypeScript coding standards and best practices"
globs: "**/*.ts,**/*.tsx"
alwaysApply: false
---

<!-- REFERENCE: See context/coding-standards/typescript.md for full details -->

When working with TypeScript:
[Content from context/coding-standards/typescript.md]
```

## Usage Patterns

### Pattern 1: Per-Project Symlink

```bash
cd ~/my-project
ln -s ~/aiconfig/context .aiconfig
ln -s ~/aiconfig/.cursor .cursor
ln -s ~/aiconfig/CLAUDE.md CLAUDE.md
```

### Pattern 2: Submodule

```bash
cd ~/my-project
git submodule add git@github.com:yourusername/aiconfig.git .aiconfig
ln -s .aiconfig/.cursor .cursor
```

### Pattern 3: Direct Clone in Project

```bash
cd ~/my-project
git clone git@github.com:yourusername/aiconfig.git .aiconfig
# Add .aiconfig to .gitignore if preferred
```

## Evolution Strategy

### Phase 1: Foundation (Current)
- ✅ Core directory structure
- ✅ Cursor integration with .mdc rules
- ✅ Claude Code integration
- ✅ Basic shared context examples

### Phase 2: Rich Context Library
- Comprehensive coding standards per language
- Workflow templates for different project types
- Prompt library for common tasks
- Testing strategies and patterns

### Phase 3: Cross-Tool Automation
- Scripts to sync context between tools
- Validation that rules are properly formatted
- Analytics on which context gets used most

### Phase 4: Project Templates
- Starter templates with aiconfig pre-configured
- Language/framework-specific configurations
- Team-shareable configurations

## Benefits

1. **Consistency**: Same coding preferences across all AI tools
2. **DRY**: Write context once, use everywhere
3. **Portability**: Works in any project, any machine
4. **Versioned**: Track how your preferences evolve
5. **Collaborative**: Share configurations with teams
6. **Smart**: Context loads automatically based on what you're working on

## Technical Details

### Cursor Rules Behavior

Based on Cursor v0.46+ behavior:

- **Rule Discovery**: Cursor scans `.cursor/rules/*.mdc` at project root
- **Nested Rules**: Can place `.cursor/rules/` in subdirectories; they scope to that directory
- **Subdirectories within .cursor/rules**: Not currently supported (as of v0.46.11)
- **Agent Intelligence**: Even with `alwaysApply: true`, agent may omit irrelevant rules
- **Glob Patterns**: Standard glob syntax, comma-separated
- **Rule Priority**: Closer scoped rules (subdirectory) can override parent rules

### Claude Code Behavior

- **CLAUDE.md**: Loaded at session start, provides persistent context
- **Skills**: Invoked via `/skill-name`, defined in `.claude/skills/*/SKILL.md`
- **Context**: Can read any file in workspace, so can reference `context/` directly

## References

This design is based on official Cursor documentation and community best practices as of January 2026.
