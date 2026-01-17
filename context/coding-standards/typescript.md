# TypeScript Coding Standards

## General Principles

- **Prefer type inference** over explicit types when the type is obvious
- **Use strict mode** (`strict: true` in tsconfig.json)
- **Avoid `any`** - use `unknown` if type is truly unknown
- **Use functional patterns** where appropriate (map, filter, reduce)
- **Prefer immutability** - use `const` by default, `readonly` for properties

## Naming Conventions

- **Variables/Functions**: `camelCase`
- **Types/Interfaces**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE` for true constants, `camelCase` for config objects
- **Private fields**: Prefix with `_` or use `#` private fields
- **Files**: `kebab-case.ts` for modules, `PascalCase.tsx` for React components

## Type Definitions

### Prefer Interfaces for Objects

```typescript
// Good
interface User {
  id: string
  name: string
  email: string
}

// Use type for unions, intersections, utilities
type Status = 'active' | 'inactive' | 'pending'
type UserWithStatus = User & { status: Status }
```

### Use Discriminated Unions

```typescript
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E }

// Usage
function handleResult<T>(result: Result<T>) {
  if (result.success) {
    console.log(result.data) // Type-safe access
  } else {
    console.error(result.error)
  }
}
```

### Generic Constraints

```typescript
// Good - specific constraints
function processItems<T extends { id: string }>(items: T[]): void {
  items.forEach(item => console.log(item.id))
}

// Avoid overly generic types
function doSomething<T>(value: T): T // Too generic if T is always a specific type
```

## Error Handling

### Prefer Result Types over Exceptions for Expected Errors

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E }

async function fetchUser(id: string): Promise<Result<User>> {
  try {
    const response = await fetch(`/api/users/${id}`)
    if (!response.ok) {
      return { ok: false, error: new Error('User not found') }
    }
    const user = await response.json()
    return { ok: true, value: user }
  } catch (error) {
    return { ok: false, error: error as Error }
  }
}
```

### Use Exceptions for Unexpected Errors

```typescript
// Throw for truly exceptional conditions
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Division by zero')
  }
  return a / b
}
```

## Async Patterns

### Prefer async/await over Promises

```typescript
// Good
async function getData(): Promise<Data> {
  const response = await fetch('/api/data')
  const data = await response.json()
  return data
}

// Avoid excessive promise chaining
```

### Handle Async Errors

```typescript
// Always handle errors in async functions
async function processData() {
  try {
    const data = await getData()
    await saveData(data)
  } catch (error) {
    console.error('Failed to process data:', error)
    throw error // Re-throw or handle as appropriate
  }
}
```

## Imports

### Organize Imports

```typescript
// 1. External dependencies
import React, { useState, useEffect } from 'react'
import { z } from 'zod'

// 2. Internal modules (absolute imports)
import { User } from '@/types/user'
import { fetchUser } from '@/api/users'

// 3. Relative imports
import { Button } from './Button'
import type { ButtonProps } from './Button.types'
```

### Prefer Named Exports

```typescript
// Good - named exports
export function formatDate(date: Date): string {
  return date.toISOString()
}

export const API_URL = 'https://api.example.com'

// Avoid default exports except for components and pages
```

## React-Specific

### Functional Components with TypeScript

```typescript
interface ButtonProps {
  label: string
  onClick: () => void
  variant?: 'primary' | 'secondary'
  disabled?: boolean
}

export function Button({
  label,
  onClick,
  variant = 'primary',
  disabled = false
}: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`btn btn-${variant}`}
    >
      {label}
    </button>
  )
}
```

### Custom Hooks

```typescript
// Custom hooks should start with 'use'
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key)
    return stored ? JSON.parse(stored) : initialValue
  })

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value))
  }, [key, value])

  return [value, setValue] as const
}
```

## Testing

### Type-Safe Test Utilities

```typescript
// Use type helpers for test data
type PartialUser = Partial<User>

function createMockUser(overrides?: PartialUser): User {
  return {
    id: '123',
    name: 'Test User',
    email: 'test@example.com',
    ...overrides
  }
}

// Tests
describe('UserService', () => {
  it('should fetch user by id', async () => {
    const mockUser = createMockUser({ name: 'John Doe' })
    // ... test implementation
  })
})
```

## Don'ts

- ❌ Don't use `any` without a very good reason
- ❌ Don't disable TypeScript errors with `@ts-ignore` (use `@ts-expect-error` if needed)
- ❌ Don't use `Function` type (use specific function signatures)
- ❌ Don't use `Object` or `{}` (use `Record<string, unknown>` or specific type)
- ❌ Don't use `var` (always use `const` or `let`)
- ❌ Don't mutate objects - create new ones (spread operator, Object.assign)

## Do's

- ✅ Use const assertions for literal types: `as const`
- ✅ Use utility types: `Partial`, `Pick`, `Omit`, `Record`, etc.
- ✅ Use branded types for domain-specific primitives
- ✅ Use enums sparingly (prefer string literal unions)
- ✅ Document complex types with JSDoc comments
- ✅ Use path aliases (`@/`) to avoid relative import hell
