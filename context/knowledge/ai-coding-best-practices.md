# AI Coding Best Practices

## Working Effectively with AI Coding Assistants

This document provides guidelines for maximizing productivity when pair programming with AI assistants like Claude Code, Cursor, GitHub Copilot, etc.

## Communication Principles

### Be Specific

```
❌ "Make this better"
✅ "Refactor this function to use async/await instead of promises and add error handling"

❌ "Add a feature"
✅ "Add a user authentication feature using JWT tokens with email/password login"

❌ "Fix the bug"
✅ "Fix the bug where the form submits twice when user clicks the submit button rapidly"
```

### Provide Context

```
Good prompt structure:

I'm working on [project/feature].
I need to [specific task].
The code should [requirements/constraints].
I prefer [coding style/patterns].

Example:
"I'm working on a React e-commerce app.
I need to add a shopping cart feature.
The cart should persist to localStorage and sync across tabs.
I prefer using React hooks and TypeScript."
```

### Iterate and Refine

```
1. Start broad: "Create a user authentication system"
2. Review output
3. Refine: "Add password strength validation"
4. Review output
5. Refine: "Add 'remember me' functionality"

Don't expect perfection on first try. Iterate.
```

## Task Decomposition

### Break Down Large Tasks

```
Instead of:
"Build a complete user management system"

Break down:
1. "Create User type definition with id, email, name, role"
2. "Create API endpoints for CRUD operations"
3. "Add authentication middleware"
4. "Create React components for user list and user form"
5. "Add user role-based access control"
```

### Use PRDs for Complex Features

For features requiring multiple steps:

1. Create a PRD (Product Requirements Document)
2. Break into user stories
3. Implement story by story
4. Test incrementally

## Code Review with AI

### Request Specific Reviews

```
Instead of:
"Review this code"

Ask for:
"Review this code for:
1. TypeScript type safety
2. Potential performance issues
3. Security vulnerabilities
4. Error handling edge cases"
```

### Security Reviews

```
Always ask AI to check for:
- SQL injection vulnerabilities
- XSS attacks
- CSRF protection
- Authentication/authorization issues
- Sensitive data exposure
- Insecure dependencies
```

## Testing with AI

### Generate Comprehensive Tests

```
"Generate unit tests for this function covering:
1. Happy path
2. Edge cases (null, undefined, empty arrays)
3. Error scenarios
4. Boundary values"
```

### Test-Driven Development

```
1. "Write a test for a function that validates email format"
2. Review test
3. "Now implement the function to pass this test"
4. Run test
5. "Refactor the implementation for better performance"
```

## Debugging with AI

### Provide Complete Error Information

```
When asking for debugging help:

1. **Error message** - Complete error and stack trace
2. **Expected behavior** - What should happen
3. **Actual behavior** - What actually happens
4. **Steps to reproduce** - How to trigger the issue
5. **Relevant code** - The code involved
6. **Context** - Environment, dependencies, etc.
```

### Example Debugging Prompt

```
I'm getting this error:
[paste full error]

Expected: User should be redirected to dashboard after login
Actual: Getting "Cannot read property 'id' of undefined"

Code:
[paste relevant code]

Using: React 18, TypeScript 5.0, Node 20
```

## Refactoring with AI

### Clear Refactoring Goals

```
"Refactor this component to:
1. Extract reusable logic into custom hooks
2. Improve TypeScript type safety
3. Add error boundaries
4. Reduce re-renders by memoization

Maintain current functionality and behavior."
```

### Validate Refactors

```
After refactoring:
1. "Compare the old and new implementation"
2. "What are the key improvements?"
3. "Are there any behavior changes?"
4. "Do all tests still pass?"
```

## Learning from AI

### Ask for Explanations

```
Don't just accept code. Ask:
- "Explain why this approach is better"
- "What are the trade-offs?"
- "When would this pattern not be appropriate?"
- "What are alternative approaches?"
```

### Document Learnings

```
After getting a solution:
1. "Summarize the key concepts used here"
2. "What resources can I read to learn more?"
3. "Add comments explaining the non-obvious parts"
```

## AI Limitations

### What AI Does Well

- ✅ Writing boilerplate code
- ✅ Implementing well-defined algorithms
- ✅ Following established patterns
- ✅ Generating tests
- ✅ Explaining code
- ✅ Finding common bugs
- ✅ Refactoring code
- ✅ Suggesting improvements

### What Requires Human Judgment

- ❌ Architecture decisions
- ❌ Business logic nuances
- ❌ UX/design choices
- ❌ Performance optimization priorities
- ❌ Security threat modeling
- ❌ Domain-specific edge cases
- ❌ Technical debt trade-offs

### Always Verify

```
Never blindly trust AI-generated code:

1. **Read the code** - Understand what it does
2. **Test thoroughly** - Don't just test happy path
3. **Review security** - Check for vulnerabilities
4. **Check performance** - Profile if needed
5. **Verify correctness** - Does it actually solve the problem?
```

## Prompt Patterns

### The Constraint Pattern

```
"Create a [X] that [does Y] with these constraints:
- Must use [technology/pattern]
- Performance: [requirement]
- Should NOT [anti-requirement]
- Must handle [edge cases]"

Example:
"Create a caching layer that stores API responses with these constraints:
- Must use Redis
- Performance: Sub-10ms lookup
- Should NOT cache user-specific data
- Must handle cache invalidation on updates"
```

### The Example Pattern

```
"Here's an example of what I want:
[example code]

Create something similar for [new use case] but:
- Change [X] to [Y]
- Add [Z]
- Remove [W]"
```

### The Persona Pattern

```
"Act as a [expert type] and [task].
Consider [specific concerns]."

Example:
"Act as a senior security engineer and review this authentication code.
Consider OWASP top 10 vulnerabilities and modern best practices."
```

### The Template Pattern

```
"Fill in this template:
[code template with placeholders]

For this use case:
[specific requirements]"
```

## Productivity Tips

### Use AI for Repetitive Tasks

```
- Converting data formats
- Writing similar tests
- Creating CRUD operations
- Generating TypeScript types from JSON
- Writing API documentation
- Creating database migrations
```

### Keep AI In Context

```
In Cursor/Claude Code:
- Reference files: @filename
- Include relevant context in conversation
- Use project rules for consistent behavior
- Leverage workspace context
```

### Iterate Quickly

```
1. Get working solution (even if not perfect)
2. Test it
3. Refine based on results
4. Optimize if needed

Perfection on first try is rare. Iteration is fast.
```

## Version Control with AI

### Commit AI-Generated Code Carefully

```
Before committing AI code:
1. Review every line
2. Understand what it does
3. Test thoroughly
4. Add your own comments if needed
5. Take ownership of the code
```

### Document AI Usage

```
In commit messages or comments:

// Generated with AI assistance and verified
// Optimized with Claude for performance

git commit -m "feat(auth): add JWT token refresh

Implementation assisted by AI, reviewed and tested.
Handles edge cases for token expiration and refresh."
```

## Anti-Patterns

### Don't Over-Rely on AI

```
❌ Asking AI for every single line of code
❌ Not understanding the code AI generates
❌ Blindly accepting suggestions
❌ Not testing AI-generated code
❌ Using AI as a crutch to avoid learning
```

### Don't Provide Insufficient Context

```
❌ "Fix this" [without showing code]
❌ "It doesn't work" [without error message]
❌ "Make it faster" [without profiling data]
❌ "Add security" [without specifying requirements]
```

## Continuous Improvement

### Track What Works

```
Keep notes on:
- Effective prompts
- Common tasks AI helps with
- Areas where AI struggles
- Workflows that work well
```

### Share Learnings

```
- Document effective prompts in your team
- Create shared context files (.cursorrules, CLAUDE.md)
- Share debugging approaches
- Build a library of reusable prompts
```

## Meta-Learning

### Ask AI to Help You Use AI Better

```
"Based on our conversation, suggest better ways I could have asked for this"
"What additional context would have been helpful?"
"How can I structure my prompts for better results?"
```

This creates a feedback loop for improvement.
