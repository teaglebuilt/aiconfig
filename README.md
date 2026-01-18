# AIConfig - Shared Context for AI Coding Assistants

> Your portable "dotfiles" for vibecoding across Claude Code, Cursor, and other AI assistants.

## Overview

AIConfig is a **shared context system** that provides consistent coding preferences, workflows, and knowledge across different AI coding tools. Think of it as "dotfiles for AI assistants" - configure once, use everywhere.

1. [Architecture](./docs/architecture.md)


## Structure

```
aiconfig/
├── context/                          # SOURCE OF TRUTH
│   ├── coding-standards/            # Language-specific standards
│   │   ├── typescript.md
│   │   └── testing.md
│   ├── workflows/                   # Development processes
│   │   ├── git-conventions.md
│   │   └── feature-development.md
│   ├── prompts/                     # Reusable prompt templates
│   │   ├── code-review.md
│   │   └── debugging.md
│   └── knowledge/                   # AI coding best practices
│       └── ai-coding-best-practices.md
│
├── .cursor/rules/                   # Cursor integration
│   ├── core-context.mdc             # Always-on context
│   ├── typescript-standards.mdc     # Auto-loads for TS files
│   ├── testing-standards.mdc        # Auto-loads for test files
│   └── git-workflow.mdc             # Git preferences
│
├── .claude/skills/                  # Claude Code skills
│   ├── generate-prd/
│   └── generate-prd-to-json/
├── CLAUDE.md                        # Claude Code main config
└── README.md                        # This file
``