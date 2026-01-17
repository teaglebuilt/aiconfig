# Testing Standards

## General Philosophy

- **Test behavior, not implementation** - Tests should validate outcomes, not internal details
- **Write tests first** when fixing bugs (TDD for bug fixes)
- **Keep tests simple** - A test should have one clear purpose
- **Tests are documentation** - They show how code should be used
- **Fast tests** - Unit tests should run in milliseconds

## Test Structure

### AAA Pattern (Arrange, Act, Assert)

```typescript
describe('UserService', () => {
  it('should create a new user with valid data', async () => {
    // Arrange - Set up test data and dependencies
    const userData = { name: 'John', email: 'john@example.com' }
    const mockDb = createMockDatabase()
    const service = new UserService(mockDb)

    // Act - Execute the code under test
    const result = await service.createUser(userData)

    // Assert - Verify the outcome
    expect(result.id).toBeDefined()
    expect(result.name).toBe(userData.name)
    expect(mockDb.insert).toHaveBeenCalledWith(expect.objectContaining(userData))
  })
})
```

## Naming Conventions

### Describe Blocks

```typescript
// Use the name of the unit being tested
describe('calculateTotal', () => {})
describe('UserService', () => {})
describe('LoginPage', () => {})
```

### Test Names

```typescript
// Format: "should [expected behavior] when [condition]"
it('should return 0 when cart is empty', () => {})
it('should throw error when user ID is invalid', () => {})
it('should render loading state when data is fetching', () => {})

// Or: "should [expected behavior]" when condition is obvious
it('should add two numbers correctly', () => {})
it('should validate email format', () => {})
```

## Unit Tests

### Characteristics

- **Isolated** - No dependencies on external systems (DB, API, filesystem)
- **Fast** - Run in milliseconds
- **Deterministic** - Same input always produces same output
- **Focused** - Test one thing at a time

### Example

```typescript
// Function to test
function calculateDiscount(price: number, discountPercent: number): number {
  if (price < 0 || discountPercent < 0 || discountPercent > 100) {
    throw new Error('Invalid input')
  }
  return price * (discountPercent / 100)
}

// Tests
describe('calculateDiscount', () => {
  it('should calculate discount correctly', () => {
    expect(calculateDiscount(100, 10)).toBe(10)
    expect(calculateDiscount(50, 20)).toBe(10)
  })

  it('should handle 0% discount', () => {
    expect(calculateDiscount(100, 0)).toBe(0)
  })

  it('should handle 100% discount', () => {
    expect(calculateDiscount(100, 100)).toBe(100)
  })

  it('should throw error for negative price', () => {
    expect(() => calculateDiscount(-100, 10)).toThrow('Invalid input')
  })

  it('should throw error for invalid discount percentage', () => {
    expect(() => calculateDiscount(100, -10)).toThrow('Invalid input')
    expect(() => calculateDiscount(100, 101)).toThrow('Invalid input')
  })
})
```

## Integration Tests

### Characteristics

- **Real dependencies** - Test actual integration between components
- **Slower** - May involve DB, API calls
- **Realistic** - Tests how components work together

### Example

```typescript
describe('UserService Integration', () => {
  let db: Database
  let service: UserService

  beforeAll(async () => {
    db = await createTestDatabase()
  })

  afterAll(async () => {
    await db.close()
  })

  beforeEach(async () => {
    await db.clear()
    service = new UserService(db)
  })

  it('should create user and retrieve by id', async () => {
    // Create
    const user = await service.createUser({
      name: 'John',
      email: 'john@example.com'
    })

    // Retrieve
    const retrieved = await service.getUserById(user.id)

    expect(retrieved).toEqual(user)
  })
})
```

## Mocking

### When to Mock

- **External services** (APIs, databases, file system)
- **Time-dependent code** (Date.now(), timers)
- **Random values** (Math.random(), UUID generation)
- **Expensive operations** (heavy computation, I/O)

### Mock Strategies

```typescript
// 1. Dependency Injection (preferred)
class UserService {
  constructor(private db: Database) {}

  async getUser(id: string) {
    return this.db.findOne({ id })
  }
}

// Test with mock
const mockDb = {
  findOne: jest.fn().mockResolvedValue({ id: '123', name: 'John' })
}
const service = new UserService(mockDb as any)

// 2. Jest mock functions
const mockFetch = jest.fn()
global.fetch = mockFetch

mockFetch.mockResolvedValue({
  ok: true,
  json: async () => ({ data: 'test' })
})

// 3. Spy on existing methods
const spy = jest.spyOn(console, 'error').mockImplementation()
// ... code that logs errors
expect(spy).toHaveBeenCalledWith('Error message')
spy.mockRestore()
```

## Test Data Builders

### Factory Pattern

```typescript
// Create test data builders
class UserBuilder {
  private user: Partial<User> = {
    id: '123',
    name: 'Test User',
    email: 'test@example.com',
    createdAt: new Date('2024-01-01')
  }

  withId(id: string) {
    this.user.id = id
    return this
  }

  withName(name: string) {
    this.user.name = name
    return this
  }

  withEmail(email: string) {
    this.user.email = email
    return this
  }

  build(): User {
    return this.user as User
  }
}

// Usage in tests
const user = new UserBuilder()
  .withId('456')
  .withName('Jane Doe')
  .build()
```

## React Component Testing

### Testing Library Principles

- **Test user behavior** - How users interact with the UI
- **Avoid implementation details** - Don't test state, props directly
- **Use accessible queries** - Prefer queries that reflect how users find elements

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { LoginForm } from './LoginForm'

describe('LoginForm', () => {
  it('should submit form with valid credentials', async () => {
    const mockOnSubmit = jest.fn()
    render(<LoginForm onSubmit={mockOnSubmit} />)

    // Find elements as users would
    const emailInput = screen.getByLabelText(/email/i)
    const passwordInput = screen.getByLabelText(/password/i)
    const submitButton = screen.getByRole('button', { name: /log in/i })

    // Simulate user interaction
    fireEvent.change(emailInput, { target: { value: 'user@example.com' } })
    fireEvent.change(passwordInput, { target: { value: 'password123' } })
    fireEvent.click(submitButton)

    // Assert outcome
    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        email: 'user@example.com',
        password: 'password123'
      })
    })
  })

  it('should show error message for invalid email', async () => {
    render(<LoginForm onSubmit={jest.fn()} />)

    const emailInput = screen.getByLabelText(/email/i)
    const submitButton = screen.getByRole('button', { name: /log in/i })

    fireEvent.change(emailInput, { target: { value: 'invalid-email' } })
    fireEvent.click(submitButton)

    expect(await screen.findByText(/invalid email/i)).toBeInTheDocument()
  })
})
```

## Test Coverage

### What to Aim For

- **80% coverage is good**, 100% is often wasteful
- **Focus on business logic** - Not getters/setters
- **Edge cases matter** - Null, undefined, empty arrays, boundary values
- **Happy path + sad paths** - Test both success and failure scenarios

### What NOT to Test

- ❌ Third-party libraries (trust they're tested)
- ❌ Framework code (React, Express, etc.)
- ❌ Trivial code (simple getters, one-line formatters)
- ❌ Configuration files
- ❌ Type definitions (TypeScript handles this)

## Best Practices

- ✅ **One assertion per test** (ideally) - Makes failures clear
- ✅ **Test error messages** - Ensure they're helpful
- ✅ **Avoid test interdependence** - Each test should run independently
- ✅ **Use descriptive test names** - Should read like documentation
- ✅ **Setup/teardown properly** - Clean state between tests
- ✅ **Test edge cases** - Empty, null, undefined, max values
- ✅ **Fast feedback loop** - Run tests on save, in CI/CD
- ✅ **Fail fast** - If a test fails, fix it immediately

## Common Pitfalls

- ❌ **Testing implementation details** - Tests break on refactors
- ❌ **Over-mocking** - Mocking everything makes tests meaningless
- ❌ **Flaky tests** - Tests that sometimes pass/fail (usually timing issues)
- ❌ **Slow tests** - If tests are slow, developers won't run them
- ❌ **Unclear failures** - Error messages that don't help debug
- ❌ **Too many assertions** - Hard to know what actually failed
