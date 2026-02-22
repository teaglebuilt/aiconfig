# How To Use AIConfig: A Real-World Walkthrough

You installed aiconfig with `make install`. You have Cursor open as your editor and Claude Code running in a separate terminal. Now what?

This guide walks through an actual workflow — starting a project, building a feature, switching between tools, and ending your session.

---

## Scenario: You're Starting a New Project

You just cloned a new repo. Open it in Cursor and open a terminal for Claude Code.

### Step 1: Initialize Project Memory

In Claude Code:

```
/init-memory
```

This creates the memory structure for your project at `~/aiconfig/memory/projects/{project-name}/`:

- `context.json` — tech stack, architecture, current focus
- `sessions.json` — history of your coding sessions
- `decisions.json` — architectural decision records

You only do this once per project.

### Step 2: Check That Context Is Loaded

Both Cursor and Claude Code now have access to:

- **Coding standards** — TypeScript conventions, testing patterns
- **Workflow guidance** — git conventions, feature development process
- **Memory** — your project's history and decisions (via MCP servers)

You don't need to configure anything. The symlinks from `make install` handle it.

---

## Scenario: Starting a New Feature

You need to build user authentication for your app.

### Step 3: Generate a PRD

In Claude Code:

```
/generate-prd
```

Describe what you want. The skill walks you through creating a Product Requirements Document with goals, user stories, acceptance criteria, and non-goals.

> **Gap identified**: The PRD is generated but not automatically linked to project memory or tracked as your current focus. You'd need to manually tell the AI "we're working on auth now" so it updates `context.json`. See [user-journey-enablement story](../stories/user-journey-enablement.story.md).

### Step 4: Get an Architecture Review

Still in Claude Code, use the architect skill:

```
/architect
```

This gives you a full architectural analysis — component breakdown, tradeoffs, patterns to consider. It can produce an ADR (Architectural Decision Record) using built-in templates.

### Step 5: Create Your Feature Branch

Ask Claude Code or do it yourself:

```bash
git checkout -b feature/user-authentication
```

This follows the branch naming conventions from `context/workflows/git-conventions.md` — both tools know these conventions.

> **Gap identified**: There is no `/start-feature` skill that combines branch creation + memory update + PRD linking in one step. You do each manually. See [user-journey-enablement story](../stories/user-journey-enablement.story.md).

---

## Scenario: Building the Feature (Cursor + Claude Code Together)

This is where having two tools shines. Use each for what it's best at.

### Cursor: Your Implementation Partner

Cursor is embedded in your editor. Use it for:

- **Writing code** — it sees your open files, cursor position, and editor context
- **Inline edits** — highlight code and ask for changes
- **Quick fixes** — "fix this type error", "add validation here"
- **Refactoring** — it understands the file you're looking at

Cursor has access to the same coding standards (TypeScript, testing) through `.cursor/rules/`.

### Claude Code: Your Terminal Strategist

Claude Code runs in your terminal. Use it for:

- **Multi-file operations** — "update all API routes to use the new auth middleware"
- **Git workflow** — commits, PRs, branch management
- **Architecture decisions** — `/architect` for deeper analysis
- **Memory operations** — `/recall`, `/log-session`
- **Running commands** — tests, builds, deployments
- **Code review** — ask it to review what you just wrote

### Example Flow

1. **Claude Code**: "Set up the auth service scaffold — types, service file, test file, route file"
2. **Cursor**: Open the service file, implement the registration logic inline
3. **Cursor**: "Write the test for this function" (it sees your implementation)
4. **Claude Code**: "Run the tests and fix any failures"
5. **Claude Code**: "Commit this with a conventional commit message"

> **Gap identified**: There is no formal way to sync what you did in Cursor with what Claude Code knows, beyond the shared filesystem. If you make extensive changes in Cursor, Claude Code doesn't automatically know what happened. You'd need to say "review what changed" or run `/log-session` to capture it. See [user-journey-enablement story](../stories/user-journey-enablement.story.md).

---

## Scenario: Switching Between Tools Mid-Session

You've been working in Cursor but need to switch to Claude Code for a complex multi-file refactor.

### Step 6: Log Before Switching (Recommended)

In whichever tool you're leaving:

```
/log-session
```

This saves what you accomplished, decisions made, and files changed.

### Step 7: Recall Context in the Other Tool

In the tool you're switching to:

```
/recall
```

Search for the feature you're working on. This pulls up past session history, decisions, and context from memory.

> **Gap identified**: There is no `/handoff` skill that packages your current state into a structured handoff document. The handoff templates exist in `templates/handoffs/` but nothing automates filling them in. You manually log and recall. See [user-journey-enablement story](../stories/user-journey-enablement.story.md).

---

## Scenario: Resuming Work Tomorrow

You closed everything last night. Today you open Cursor and Claude Code again.

### Step 8: Recall Where You Left Off

In Claude Code:

```
/recall
```

Search for your project or feature name. It returns your last session log, decisions, and current focus.

> **Gap identified**: There is no session-start hook that auto-loads your last context. There is no `/resume` skill that says "I'm back, show me where I left off and what's next." You manually search with `/recall`. See [user-journey-enablement story](../stories/user-journey-enablement.story.md).

---

## Scenario: Ending Your Session

### Step 9: Log Your Session

In Claude Code:

```
/log-session
```

The skill captures:
- What you accomplished
- Files changed
- Decisions made
- Follow-ups and TODOs

This is stored in `sessions.json` and available via `/recall` next time.

The session-end hook will also remind you to log if you forget.

---

## Quick Reference

| What You Want | Tool | Command |
|---|---|---|
| Initialize project memory | Claude Code | `/init-memory` |
| Plan a feature | Claude Code | `/generate-prd` |
| Architecture analysis | Claude Code | `/architect` |
| Write code inline | Cursor | Chat in editor |
| Multi-file changes | Claude Code | Describe the change |
| Run tests | Claude Code | Ask it to run them |
| Search past context | Either | `/recall` |
| Log your work | Either | `/log-session` |
| Git operations | Claude Code | Ask for commits/PRs |

---

## What's Not Supported Yet

Several parts of the end-to-end journey require manual steps that could be automated. These are tracked in the [User Journey Enablement story](../stories/user-journey-enablement.story.md):

- No single command to start a feature (branch + memory + focus)
- No auto-resume when opening a project
- No automated handoff between tools
- No cross-client activity visibility
- No status check ("where am I? what was I doing?")
- PRD not auto-linked to memory
