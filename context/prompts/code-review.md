# Code Review Prompts

## General Code Review

```
Please review this code for:

1. **Correctness** - Does it work as intended?
2. **Testing** - Are there sufficient tests? Edge cases covered?
3. **Readability** - Is it easy to understand?
4. **Performance** - Any obvious performance issues?
5. **Security** - Any vulnerabilities (XSS, SQL injection, etc.)?
6. **Error Handling** - Are errors handled gracefully?
7. **Type Safety** - Proper TypeScript usage?
8. **Best Practices** - Follows our coding standards?

Provide specific suggestions for improvement.
```

## Security-Focused Review

```
Please perform a security review of this code:

1. **Input Validation** - All user inputs properly validated?
2. **Authentication/Authorization** - Access controls correct?
3. **Data Sanitization** - XSS/injection prevention?
4. **Secrets** - No hardcoded credentials or API keys?
5. **Dependencies** - No known vulnerabilities?
6. **Error Messages** - No sensitive info leaked?
7. **HTTPS/Encryption** - Sensitive data protected?
8. **OWASP Top 10** - Check against common vulnerabilities

Flag any security concerns with severity: CRITICAL, HIGH, MEDIUM, LOW.
```

## Performance Review

```
Please review this code for performance:

1. **Algorithms** - Time/space complexity appropriate?
2. **Database Queries** - N+1 queries? Proper indexing?
3. **Caching** - Opportunities for caching?
4. **Network Calls** - Batching possible? Unnecessary requests?
5. **Memory** - Any memory leaks? Large object creation?
6. **Rendering** - React re-renders optimized?
7. **Bundle Size** - Unnecessary dependencies?
8. **Async Operations** - Parallelizable operations?

Suggest specific optimizations with estimated impact.
```

## Refactoring Review

```
I've refactored [component/module]. Please verify:

1. **Behavior Preserved** - Does it still work the same?
2. **Test Coverage** - All tests still pass?
3. **Improvements** - Is it actually better?
4. **Simplification** - Is it simpler to understand?
5. **Maintainability** - Easier to modify in future?
6. **Breaking Changes** - Any API changes?
7. **Performance** - Same or better performance?

Let me know if the refactoring achieves its goals.
```

## API Design Review

```
Please review this API design:

1. **RESTful** - Follows REST principles?
2. **Consistency** - Naming conventions consistent?
3. **Versioning** - Version strategy clear?
4. **Error Responses** - Consistent error format?
5. **Documentation** - Well documented?
6. **Validation** - Input validation comprehensive?
7. **Security** - Authentication/authorization proper?
8. **Backwards Compatibility** - Breaking changes handled?

Suggest improvements to the API design.
```

## Test Review

```
Please review these tests:

1. **Coverage** - Important scenarios covered?
2. **Edge Cases** - Boundaries tested?
3. **Clarity** - Test names descriptive?
4. **Independence** - Tests don't depend on each other?
5. **Assertions** - Clear, specific assertions?
6. **Mocking** - Appropriate use of mocks?
7. **Performance** - Tests run quickly?
8. **Maintainability** - Easy to update when code changes?

Identify any missing test cases.
```

## Architecture Review

```
Please review this architectural design:

1. **Separation of Concerns** - Responsibilities clearly separated?
2. **Scalability** - Can it handle growth?
3. **Maintainability** - Easy to modify and extend?
4. **Dependencies** - Coupling minimized?
5. **Data Flow** - Clear, unidirectional where appropriate?
6. **Error Handling** - Errors propagate correctly?
7. **Testing** - Design testable?
8. **Trade-offs** - Aware of design trade-offs?

Suggest architectural improvements.
```

## Accessibility Review

```
Please review this UI code for accessibility:

1. **Semantic HTML** - Proper HTML elements used?
2. **ARIA** - Correct ARIA labels and roles?
3. **Keyboard Navigation** - All interactive elements keyboard accessible?
4. **Screen Readers** - Content readable by screen readers?
5. **Color Contrast** - Sufficient contrast ratios?
6. **Focus Management** - Visible focus indicators?
7. **Forms** - Labels associated with inputs?
8. **Alt Text** - Images have descriptive alt text?

Flag accessibility issues by WCAG level (A, AA, AAA).
```

## Database Schema Review

```
Please review this database schema:

1. **Normalization** - Properly normalized?
2. **Indexes** - Appropriate indexes for queries?
3. **Constraints** - Foreign keys, unique constraints?
4. **Data Types** - Appropriate types for each field?
5. **Migrations** - Migration safe and reversible?
6. **Performance** - Query performance considerations?
7. **Scalability** - Can schema handle growth?
8. **Naming** - Consistent naming conventions?

Suggest schema improvements.
```
