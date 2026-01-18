# Debugging Prompts

## General Bug Investigation

```
I'm encountering a bug: [describe issue]

Please help me debug this by:

1. **Understand** - What should happen vs what's happening?
2. **Reproduce** - Minimal steps to reproduce
3. **Isolate** - Which component/function is responsible?
4. **Root Cause** - What's the underlying issue?
5. **Fix** - Suggested solution(s)
6. **Test** - How to verify the fix?
7. **Prevent** - How to prevent similar bugs?

Include code examples and explanations.
```

## Error Message Analysis

```
I'm getting this error:

[paste error message and stack trace]

Please analyze:

1. **Error Type** - What kind of error is this?
2. **Root Cause** - What's causing it?
3. **Location** - Where in the code is it failing?
4. **Context** - What was the code trying to do?
5. **Fix** - How to resolve it?
6. **Prevention** - How to avoid this in future?

Walk me through the debugging process.
```

## Performance Issue

```
I'm experiencing performance issues: [describe slowness]

Help me investigate:

1. **Measurement** - How to measure the performance issue?
2. **Profiling** - What profiling tools should I use?
3. **Bottlenecks** - Where is the code slow?
4. **Analysis** - Why is it slow?
5. **Optimization** - What can be optimized?
6. **Trade-offs** - What are the trade-offs?
7. **Verification** - How to verify improvements?

Provide specific optimization suggestions.
```

## Intermittent Bug

```
I have a bug that occurs inconsistently: [describe]

Help me debug this race condition/timing issue:

1. **Patterns** - When does it occur?
2. **Conditions** - What conditions trigger it?
3. **Async Code** - Are there async operations involved?
4. **State Management** - Could it be state-related?
5. **Logging** - What logging should I add?
6. **Reproduction** - How to make it reproducible?
7. **Fix** - How to fix race conditions?

Suggest debugging strategies for intermittent issues.
```

## Memory Leak Investigation

```
I suspect a memory leak: [describe symptoms]

Help me investigate:

1. **Symptoms** - What indicates a memory leak?
2. **Profiling** - How to profile memory usage?
3. **Heap Snapshots** - How to analyze heap snapshots?
4. **Common Causes** - What typically causes memory leaks?
   - Event listeners not removed?
   - Closures holding references?
   - Large objects not garbage collected?
   - Timers not cleared?
5. **Detection** - How to pinpoint the leak?
6. **Fix** - How to resolve it?

Provide step-by-step debugging process.
```

## Production Bug

```
There's a bug in production: [describe]

This is urgent. Help me:

1. **Assess Impact** - How many users affected?
2. **Quick Fix** - Immediate workaround possible?
3. **Root Cause** - What's the actual issue?
4. **Rollback** - Should we rollback?
5. **Hotfix** - How to deploy a hotfix?
6. **Monitoring** - What to monitor?
7. **Prevention** - Why did this reach production?

Prioritize quick mitigation over perfect solution.
```

## TypeScript Type Error

```
I'm getting a TypeScript error: [paste error]

Help me understand and fix:

1. **Error Interpretation** - What is TypeScript saying?
2. **Type Mismatch** - Where are types incompatible?
3. **Expected vs Actual** - What types are involved?
4. **Root Cause** - Why is this a type error?
5. **Solutions** - Possible fixes:
   - Type assertion (if safe)
   - Type guard
   - Type narrowing
   - Generic constraints
   - Refactor types
6. **Best Solution** - Which fix is most type-safe?

Explain the type system concepts involved.
```

## API Integration Issue

```
I'm having trouble integrating with an API: [describe]

Debug this integration:

1. **Request** - What's being sent?
2. **Response** - What's being received?
3. **Expected** - What should happen?
4. **Actual** - What actually happens?
5. **Headers** - Are headers correct?
6. **Authentication** - Auth working properly?
7. **Error Handling** - Errors handled?
8. **Network** - Network issues? CORS?

Provide debugging steps and curl commands.
```

## React Rendering Issue

```
I have a React rendering issue: [describe]

Help me debug:

1. **Expected Behavior** - What should render?
2. **Actual Behavior** - What actually renders?
3. **Component Tree** - What's the component structure?
4. **Props** - Are props being passed correctly?
5. **State** - Is state updating as expected?
6. **Re-renders** - Unnecessary re-renders?
7. **Console Logs** - What do logs show?
8. **React DevTools** - What do DevTools show?

Suggest debugging approach and potential fixes.
```

## Build/Bundle Error

```
I'm getting a build error: [paste error]

Help me resolve:

1. **Error Location** - Which file/dependency is causing this?
2. **Configuration** - Is build config correct?
3. **Dependencies** - Dependency conflict?
4. **Module Resolution** - Import path issues?
5. **TypeScript** - tsconfig issue?
6. **Webpack/Vite** - Bundler configuration?
7. **Clean Build** - Have I tried clean build?
8. **Fix** - How to resolve?

Provide step-by-step resolution.
```

## Test Failure

```
A test is failing: [describe test]

Help me debug:

1. **Test Code** - Show me the test
2. **Expected** - What should the test expect?
3. **Actual** - What's actually happening?
4. **Mocks** - Are mocks set up correctly?
5. **Async** - Async timing issues?
6. **Test Environment** - Environment different from production?
7. **Isolation** - Test interdependence?
8. **Fix** - How to fix the test?

Determine if it's a bug in code or test.
```

## Debugging Best Practices

### Systematic Approach

1. **Reproduce** - Get consistent reproduction steps
2. **Isolate** - Narrow down to smallest failing code
3. **Hypothesize** - Form theory about cause
4. **Test** - Test the hypothesis
5. **Fix** - Apply the fix
6. **Verify** - Confirm fix works
7. **Reflect** - Understand why it happened

### Debugging Tools

```typescript
// Console logging (basic but effective)
console.log('User data:', user)
console.table(users) // For arrays/objects
console.time('operation')
// ... code
console.timeEnd('operation')

// Debugger statement
function processData(data) {
  debugger // Execution pauses here
  return data.map(item => item.value)
}

// Conditional breakpoint
if (user.id === 'problematic-id') {
  debugger
}

// Network debugging
console.log('Request:', request)
console.log('Response:', await response.json())

// React debugging
console.log('Props:', props)
console.log('State:', state)
useEffect(() => {
  console.log('Effect ran with:', dependencies)
}, [dependencies])
```

### Prevention

After fixing a bug:

```markdown
1. **Add test** - Prevent regression
2. **Update docs** - If API misunderstood
3. **Improve error messages** - Make debugging easier
4. **Add validation** - Catch earlier
5. **Share learnings** - Help team avoid same bug
```
