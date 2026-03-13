# Cursor Skills

Source: https://cursor.com/docs/skills

## Overview

Skills provide reusable capabilities to the agent.

They act like domain-specific instructions.

Examples:

* Playwright testing
* Database migrations
* Code review

## Skill Structure

Skills are defined in Markdown.

Example:

```
.cursor/skills/my-skill/SKILL.md
```

Example frontmatter:

```
---
name: my-skill
description: When to use this skill
---
```

## Example Skill

```
---
name: playwright-test
description: Run end-to-end browser tests
---

# Playwright Testing

## When to Use
Use when verifying UI functionality.

## Steps
1. Start dev server
2. Run playwright tests
3. Capture screenshots
```

## Invocation

Skills can be used:

Automatically by the agent

or manually:

```
/playwright-test
```

## Best Practices

* Clear description
* Specific instructions
* Reusable patterns
