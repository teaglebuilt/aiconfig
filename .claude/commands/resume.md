---
allowed-tools: Read, Bash, Glob, Grep
description: Resume a previous Claude Code session by loading its context bundle
argument-hint: [session_id or partial session name]
---

# Resume Session

Load and summarize a previous Claude Code session's context to continue where you left off.

## Variables

SESSION_IDENTIFIER: $ARGUMENTS
CONTEXT_BUNDLES_DIR: `.claude/context_bundles`

## Instructions

Your task is to help the user resume a previous session by loading its context bundle and providing a clear summary of what was accomplished and what might need continuation.

### Step 1: Find the Session

If SESSION_IDENTIFIER is provided:
- Search for context bundle files matching the identifier in CONTEXT_BUNDLES_DIR
- Support both full session IDs and partial matches (e.g., "12_oct" matches "12_oct_session_...")

If no SESSION_IDENTIFIER is provided:
- List the 5 most recent context bundle files
- Display them with creation timestamps
- Ask the user which one to load

### Step 2: Load the Context Bundle

Once you've identified the correct session file:
- Read the JSON context bundle
- Parse the operations array to understand what happened in that session

### Step 3: Analyze the Session

Extract and analyze:
- **File Operations**: Which files were read, written, or edited
- **Commands Executed**: What bash commands were run
- **Tools Used**: Pattern of tool usage (glob, grep, etc.)
- **Todo Items**: If any todos were tracked, what was their state
- **Session Flow**: Reconstruct the narrative of what the user was working on

### Step 4: Provide Context Summary

Generate a concise summary including:

```
📋 Session Resume: [session_id]
Created: [timestamp]
Duration: [time span of operations]

## What Was Done:
- [Key accomplishment 1]
- [Key accomplishment 2]
- [Key accomplishment 3]

## Files Touched:
- [file1] - [what was done]
- [file2] - [what was done]

## Current State:
[Brief description of where things were left]

## Suggested Next Steps:
- [logical continuation 1]
- [logical continuation 2]

Ready to continue from where you left off!
```

### Step 5: Load Related Files

If the session involved specific files that would be helpful for context:
- Proactively read 2-3 of the most important files that were being worked on
- This gives you immediate context to continue the work

## Examples

Example 1 - With full session ID:
```
/resume f9c46c92-05d2-41a5-a078-fc94d711b9b5
```

Example 2 - With partial match:
```
/resume 12_oct_session
```

Example 3 - List recent sessions:
```
/resume
```

## Notes

- Context bundles are automatically created by the `context_bundle_builder.py` hook
- They track all tool operations during a session
- This command helps bridge conversations and maintain continuity
- Be intelligent about what details to include - focus on actionable insights
