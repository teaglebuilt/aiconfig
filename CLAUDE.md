# Claude Code Configuration

Welcome to the AIConfig shared context system. This configuration provides consistent coding preferences and workflows across vibe coding clients

## Overview

This repository serves as a **portable AI configuration** ("aiconfig") that works across multiple AI coding tools.

**ALWAYS** reference @README.md

### Clients

- **Claude Code** `.claude`
- **Cursor** (via `.cursor/rules`)

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
