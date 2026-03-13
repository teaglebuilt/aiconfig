---
description: Check latest Claude Code and Cursor releases, compare against known state, and identify gaps in aiconfig's coverage.
---

# Vibe Check — Client Version & Capability Tracker

You are running a vibe check for the aiconfig repository. Your goal is to understand what the latest versions and capabilities of our target clients (Claude Code and Cursor) are, compare against what we last recorded, and surface actionable gaps.

## Procedure

### Step 1: Load Current State

Read `memory/global/vibe_check.json` to understand:
- What versions we last recorded for each client
- When we last ran this check
- What notable features were tracked

### Step 2: Fetch Latest Versions

For **Claude Code**:
- Search the web for the latest Claude Code CLI release version (check GitHub releases at https://github.com/anthropics/claude-code/releases)
- Search for recent Claude Code changelog entries, new features, or announcements
- Look for changes to: hooks, skills, agents, MCP support, commands, settings, sub-agents, context management

For **Cursor**:
- Search the web for the latest Cursor editor version and changelog (https://www.cursor.com/changelog)
- Search for recent Cursor feature announcements
- Look for changes to: agents, rules (.mdc), MCP support, hooks, plugins, skills detection, context system

### Step 3: Diff Against Known State

Compare what you found against the stored state:
- **Version bumps**: Has either client released a new version since our last check?
- **New capabilities**: Are there new features that aiconfig should leverage or account for?
- **Breaking changes**: Are there deprecations or breaking changes that affect our config?
- **Gap analysis**: Are there new extension mechanisms we're not using? Are any of our patterns now obsolete?

### Step 4: Report

Present a structured report:

```
## Vibe Check Report — {today's date}

### Claude Code
- **Current version**: {version}
- **Last known version**: {from state file}
- **Status**: {UP TO DATE | BEHIND | FIRST CHECK}
- **New since last check**:
  - {list of notable changes}
- **Gaps for aiconfig**:
  - {things we should update or add}

### Cursor
- **Current version**: {version}
- **Last known version**: {from state file}
- **Status**: {UP TO DATE | BEHIND | FIRST CHECK}
- **New since last check**:
  - {list of notable changes}
- **Gaps for aiconfig**:
  - {things we should update or add}

### Recommendations
Priority items for aiconfig to address:
1. {highest priority gap}
2. {next priority}
...
```

### Step 5: Update State

Update `memory/global/vibe_check.json` with:
- New version numbers for each client
- Today's date as `last_checked`
- Notable features discovered added to the arrays
- A new entry in the `runs` array:

```json
{
  "date": "YYYY-MM-DD",
  "claude_code_version": "x.y.z",
  "cursor_version": "x.y.z",
  "gaps_found": ["brief description of each gap"],
  "actions_taken": []
}
```

### Step 6: Update Docs (if needed)

If significant new features were found, update the relevant docs in `context/knowledge/docs/`:
- `context/knowledge/docs/claude_code/` — for Claude Code changes
- `context/knowledge/docs/cursor/` — for Cursor changes

Use the `/scrape` skill or WebFetch to pull latest documentation if a major version change is detected.

## Important Notes

- This command is about **awareness**, not implementation. Report gaps but don't refactor aiconfig in this workflow.
- Focus on features relevant to aiconfig's mission: portable config, shared context, skills, agents, hooks, MCP.
- When in doubt about a version, note the uncertainty rather than guessing.
- The `runs` history lets us see the cadence of changes over time — useful for deciding how often to run this.
