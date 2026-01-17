# AIConfig - Shared Context for AI Coding Assistants

> Your portable "dotfiles" for vibecoding across Claude Code, Cursor, and other AI assistants.

## Overview

AIConfig is a **shared context system** that provides consistent coding preferences, workflows, and knowledge across different AI coding tools. Think of it as "dotfiles for AI assistants" - configure once, use everywhere.

### Why AIConfig?

- ✅ **Single Source of Truth** - Write your coding preferences once
- ✅ **Multi-Tool Support** - Works with Claude Code, Cursor, and more
- ✅ **Version Controlled** - Track evolution of your AI coding preferences
- ✅ **Portable** - Use in any project via symlinks, submodules, or direct clone
- ✅ **Smart Scoping** - Context auto-loads based on file types and patterns
- ✅ **Composable** - Pick and choose which context to apply

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
│
├── CLAUDE.md                        # Claude Code main config
├── DESIGN.md                        # Architecture documentation
└── README.md                        # This file
```

## Quick Start

### For Claude Code

1. Clone this repository:
   ```bash
   git clone <your-repo-url> ~/aiconfig
   ```

2. In any project, symlink the CLAUDE.md file:
   ```bash
   cd ~/my-project
   ln -s ~/aiconfig/CLAUDE.md CLAUDE.md
   ```

3. Start Claude Code - it will automatically load the configuration!

### For Cursor

1. Clone this repository:
   ```bash
   git clone <your-repo-url> ~/aiconfig
   ```

2. In any project, symlink the `.cursor` directory:
   ```bash
   cd ~/my-project
   ln -s ~/aiconfig/.cursor .cursor
   ```

3. Restart Cursor - rules will automatically load based on file types!

### For Both

Symlink both configurations:
```bash
cd ~/my-project
ln -s ~/aiconfig/CLAUDE.md CLAUDE.md
ln -s ~/aiconfig/.cursor .cursor
```

## How It Works

### Cursor Integration

Cursor uses **Project Rules** (`.cursor/rules/*.mdc` files) that:

- **Auto-load based on file patterns** - TypeScript rules load when editing `.ts` files
- **Always-on context** - Core preferences are always available
- **Smart relevance** - Cursor's agent decides when to apply rules
- **Scoped rules** - Place `.cursor/rules/` in subdirectories for scoped context

**Example rule frontmatter:**
```yaml
---
description: "TypeScript coding standards"
globs: "**/*.ts,**/*.tsx"      # Auto-load for TS files
alwaysApply: false              # Only when relevant
---
```

### Claude Code Integration

Claude Code uses:

- **CLAUDE.md** - Main configuration file loaded at session start
- **Skills** - Custom slash commands in `.claude/skills/`
- **Direct file access** - Can read context files directly

### Shared Context

The `context/` directory contains canonical knowledge in markdown:

- **coding-standards/** - How to write code (TypeScript, testing, etc.)
- **workflows/** - How to work (git, PRs, feature development)
- **prompts/** - Reusable templates (code review, debugging)
- **knowledge/** - General best practices (AI coding tips)

Tool adapters **reference** these files rather than duplicating content.

## Usage Patterns

### Pattern 1: Global Symlinks (Recommended)

Install once, use everywhere:

```bash
# Clone to home directory
cd ~
git clone <repo-url> aiconfig

# In each project
cd ~/my-project
ln -s ~/aiconfig/CLAUDE.md CLAUDE.md
ln -s ~/aiconfig/.cursor .cursor
```

**Benefits**: One source of truth, updates apply to all projects

### Pattern 2: Git Submodule

Version-lock aiconfig per project:

```bash
cd ~/my-project
git submodule add <repo-url> .aiconfig
ln -s .aiconfig/CLAUDE.md CLAUDE.md
ln -s .aiconfig/.cursor .cursor
git add .gitmodules .aiconfig CLAUDE.md .cursor
git commit -m "chore: add aiconfig submodule"
```

**Benefits**: Each project can use different aiconfig versions

### Pattern 3: Direct Clone

Standalone installation:

```bash
cd ~/my-project
git clone <repo-url> .aiconfig
ln -s .aiconfig/CLAUDE.md CLAUDE.md
ln -s .aiconfig/.cursor .cursor
# Optionally add .aiconfig to .gitignore
```

**Benefits**: Simple, no submodule complexity

## Customization

### Adding Context

Create new files in `context/`:

```bash
# Add Python coding standards
touch context/coding-standards/python.md

# Add debugging workflow
touch context/workflows/debugging-process.md
```

### Adding Cursor Rules

Create new `.mdc` files:

```bash
# Create rule for Python files
cat > .cursor/rules/python-standards.mdc << 'EOF'
---
description: "Python coding standards"
globs: "**/*.py"
alwaysApply: false
---

# Python Standards

See context/coding-standards/python.md for details.

[Add quick reference here]
EOF
```

### Updating Existing Context

Edit files in `context/` - changes apply to all tools:

```bash
# Edit TypeScript standards
vim context/coding-standards/typescript.md

# Changes automatically apply to:
# - Claude Code (via CLAUDE.md)
# - Cursor (via .cursor/rules/typescript-standards.mdc)
```

## What's Included

### Coding Standards

- **TypeScript** - Type safety, naming conventions, patterns, React best practices
- **Testing** - Testing philosophy, AAA pattern, mocking strategies, coverage targets

### Workflows

- **Git Conventions** - Commit messages (Conventional Commits), branch naming, PR process
- **Feature Development** - Planning, TDD, incremental commits, review checklist

### Prompts

- **Code Review** - Templates for security, performance, architecture reviews
- **Debugging** - Systematic debugging approaches, error analysis, performance investigation

### Knowledge

- **AI Coding Best Practices** - How to communicate with AI, iterate effectively, avoid pitfalls

### Claude Code Skills

- **/generate-prd** - Create Product Requirements Documents with user stories
- **/generate-prd-to-json** - Convert PRDs to JSON format for autonomous agents

## Core Principles

The configuration enforces these principles:

### Type Safety
- Use TypeScript with `strict: true`
- Avoid `any`, prefer `unknown`
- Use discriminated unions for complex state

### Code Quality
- Functional patterns (immutability, pure functions)
- Result types for expected errors
- 80% test coverage target
- Small, focused functions

### Git Workflow
- Conventional commits: `type(scope): subject`
- Descriptive branches: `type/short-description`
- Atomic commits (one logical change)
- Self-review before requesting review

### Development Process
- Break large tasks into steps
- Write tests as you go (TDD)
- Commit incrementally
- Think critically, catch issues early

## Benefits

1. **Consistency** - Same preferences across all AI tools
2. **Efficiency** - No need to re-explain preferences in each session
3. **Quality** - Codified best practices enforced automatically
4. **Portability** - Works in any project, any machine
5. **Collaboration** - Share configurations with team members
6. **Evolution** - Track how your preferences change over time

## Advanced Usage

### Per-Directory Rules (Cursor)

Create scoped rules in subdirectories:

```bash
mkdir -p src/api/.cursor/rules
cat > src/api/.cursor/rules/api-conventions.mdc << 'EOF'
---
description: "API-specific conventions"
alwaysApply: true
---

APIs in this directory should:
- Use Express.js patterns
- Include OpenAPI documentation
- Handle errors with middleware
EOF
```

### Project-Specific Overrides

Create a local CLAUDE.md that extends the shared one:

```markdown
# Project-Specific Config

This project uses the shared aiconfig but with these additions:

- We use Prisma for database access
- API routes are in src/pages/api/
- We use Next.js 14 with App Router

For general preferences, see ~/aiconfig/CLAUDE.md
```

### Custom Skills

Add project-specific Claude Code skills:

```bash
mkdir -p .claude/skills/my-skill
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
# My Custom Skill

This skill does [X]...
EOF
```

## Troubleshooting

### Cursor not loading rules

1. Check that `.cursor/rules/` exists in project root
2. Verify `.mdc` files have valid frontmatter (YAML between `---`)
3. Restart Cursor IDE
4. Check Cursor logs for errors

### Claude Code not finding context

1. Verify `CLAUDE.md` exists in project root
2. Check symlinks: `ls -la CLAUDE.md`
3. Ensure context files exist: `ls ~/aiconfig/context/`

### Rules not applying

**Cursor:**
- Check `globs` patterns match your files
- Try `alwaysApply: true` for testing
- Remember: Agent decides relevance even for always-applied rules

**Claude Code:**
- Context is always available but may not be mentioned
- Ask explicitly: "What are the TypeScript standards from CLAUDE.md?"

## Contributing to Your AIConfig

As you learn and refine your preferences:

1. **Update context files** - Keep standards current
2. **Add new rules** - Create rules for new languages/tools
3. **Refine prompts** - Improve prompt templates based on what works
4. **Document learnings** - Add to knowledge/ directory
5. **Version control** - Commit changes with clear messages

```bash
cd ~/aiconfig
git add context/coding-standards/python.md
git commit -m "docs(standards): add Python coding standards"
git push
```

All your projects using aiconfig will get the updates!

## Examples

See `DESIGN.md` for detailed architecture and design decisions.

## Philosophy

This configuration embodies **vibecoding** - a smooth, efficient development flow where:

- 🧠 Context is always available
- 📏 Standards are consistent
- 🔄 Workflows are clear
- 🤖 AI assistants are aligned
- ✨ Quality is maintained
- ⚡ Speed is preserved

Your AI assistant isn't just a code generator - it's a coding partner that understands your preferences and helps you build quality software.

## License

MIT (or whatever license you choose)

## Resources

**Cursor Documentation:**
- [Cursor Rules](https://docs.cursor.com/context/rules)
- [Project Rules](https://cursor.com/docs/context/rules)

**Claude Code:**
- [Documentation](https://docs.anthropic.com/claude/docs)
- [GitHub](https://github.com/anthropics/claude-code)

## Next Steps

1. Clone this repo to `~/aiconfig`
2. Symlink into your projects
3. Customize `context/` files to your preferences
4. Start coding with consistent AI assistance!

---

Built for vibecoding 🎸
