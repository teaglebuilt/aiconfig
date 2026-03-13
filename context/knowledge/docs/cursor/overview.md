# Cursor Agent Prompting

Source: https://cursor.com/docs/agent/prompting

## Principles

Good prompts:

* Clearly define the goal
* Provide relevant files
* Avoid unnecessary context

## Recommended Prompt Structure

Goal → Context → Constraints → Output

Example:

```
Goal:
Add caching to the user service.

Context:
User service located in /services/user.ts

Constraints:
Use Redis
Follow existing error handling patterns

Output:
Working implementation with tests
```

## Referencing Files

You can reference files explicitly.

Example:

```
Update @src/api/user.ts to include pagination.
```

## Iterative Workflow

Best practice:

1. Start with high level request
2. Review changes
3. Refine prompt
4. Repeat

## Task Isolation

Use separate chats for separate tasks.

This prevents context overload and improves results.

## Example Prompts

Bug fixing:

```
Find the bug causing the login endpoint to return 500 errors.
```

Feature development:

```
Add Stripe checkout flow with webhook handling.
```

Refactoring:

```
Convert this service to dependency injection pattern.
```

## Prompting Tips

* Avoid overly long prompts
* Reference code instead
* Provide clear acceptance criteria
