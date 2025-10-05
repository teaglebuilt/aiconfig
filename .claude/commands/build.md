---
description: Build the codebase using the plan
argument-hint: [path-to-plan]
allowed-tools: Read, Write, Bash
---

# Build

Follow the `Workflow` to implement the `PATH_TO_PLAN` and then `Report` the completed work.

## Variables

PATH_TO_PLAN: $ARGUMENTS

## Workflow

- If no `PATH_TO_PLAN` is provided, STOP immediately and ask the user to provide it.
- Read the plan at `PATH_TO_PLAN`. Think hard about the plan and implement it into the codebase.

## Report

- Summarize the work you have completed into a consice bullet point list.
- Report the files and total lines changed with `git diff --stat`

