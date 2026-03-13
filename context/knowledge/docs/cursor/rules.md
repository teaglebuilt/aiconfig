# Cursor Rules

Source: https://cursor.com/docs/rules

## Overview

Rules provide persistent instructions to the agent.

They guide how the agent writes and edits code.

Rules are typically stored in:

```
.cursorrules
```

## Example Rules

```
- Use TypeScript strict mode
- Prefer functional components
- Use Zod for validation
- Use TanStack Query for data fetching
```

## Why Rules Matter

Rules help enforce:

* coding standards
* architecture patterns
* consistent outputs

## Example Rule File

```
# Project Rules

## Architecture
Use hexagonal architecture.

## Testing
All services require unit tests.

## Formatting
Use Prettier defaults.
```

## Best Practices

* Keep rules concise
* Avoid large documents
* Focus on conventions
