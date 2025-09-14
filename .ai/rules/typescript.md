# TypeScript Rules

- Always use TypeScript interfaces for object shapes
- Use type aliases sparingly, prefer interfaces
- Include proper JSDoc comments for public APIs
- Use strict null checks
- Prefer readonly arrays and properties where possible
- modularize components into smaller, reusable pieces
- Use nullish coalescing (`??`) and optional chaining (`?.`) operators appropriately
- Prefix unused variables with underscore (e.g., \_unusedParam)

# TypeScript Best Practices

## Type Safety & Configuration

- Enable `strict: true` in @tsconfig.json with additional flags:
  - `noImplicitAny: true`
  - `strictNullChecks: true`
  - `strictFunctionTypes: true`
  - `strictBindCallApply: true`
  - `strictPropertyInitialization: true`
  - `noImplicitThis: true`
  - `alwaysStrict: true`
  - `exactOptionalPropertyTypes: true`
- Never use `// @ts-ignore` or `// @ts-expect-error` without explanatory comments
- Use `--noEmitOnError` compiler flag to prevent generating JS files when TypeScript errors exist

## Type Definitions

- Do not ever use `any`. Ever. If you feel like you have to use `any`, use `unknown` instead.
- Explicitly type function parameters, return types, and object literals.
- Please don't ever use Enums. Use a union if you feel tempted to use an Enum.
- Use `readonly` modifiers for immutable properties and arrays
- Leverage TypeScript's utility types (`Partial`, `Required`, `Pick`, `Omit`, `Record`, etc.)
- Use discriminated unions with exhaustiveness checking for type narrowing

## Advanced Patterns

- Implement proper generics with appropriate constraints
- Use mapped types and conditional types to reduce type duplication
- Leverage `const` assertions for literal types
- Implement branded/nominal types for type-level validation

## Code Organization

- Organize types in dedicated files (types.ts) or alongside implementations
- Document complex types with JSDoc comments
- Create a central `types.ts` file or a `src/types` directory for shared types

# JavaScript Best Practices

- Use `const` for all variables that aren't reassigned, `let` otherwise
- Don't use `await` in return statements (return the Promise directly)
- Always use curly braces for control structures, even for single-line blocks
- Prefer object spread (e.g. `{ ...args }`) over `Object.assign`
- Use rest parameters instead of `arguments` object
- Use template literals instead of string concatenation

# Import Organization

- Keep imports at the top of the file
- Group imports in this order: `built-in → external → internal → parent → sibling → index → object → type`
- Add blank lines between import groups
- Sort imports alphabetically within each group
- Avoid duplicate imports
- Avoid circular dependencies
- Ensure member imports are sorted (e.g., `import { A, B, C } from 'module'`)

# Console Usage

- Console statements are allowed but should be used judiciously

**Keep in Mind**: The code will be parsed using TypeScript compiler with strict type checking enabled and should adhere to modern ECMAScript standards.

# Type Validation with Zod

You are an expert TypeScript developer who understands that type assertions (using `as`) only provide compile-time safety without runtime validation.

## Zod Over Type Assertions

- **NEVER** use type assertions (with `as`) for external data sources, API responses, or user inputs
- **ALWAYS** use Zod schemas to validate and parse data from external sources
- Implement proper error handling for validation failures

## Zod Implementation Patterns

- Import zod with: `import { z } from 'zod'`
- Define schemas near related types or in dedicated schema files
- Use `schema.parse()` for throwing validation behavior
- Use `schema.safeParse()` for non-throwing validation with detailed errors
- Add meaningful error messages with `.refine()` and `.superRefine()`
- Set up default values with `.default()` when appropriate
- Use transformations with `.transform()` to convert data formats
- Always handle potential validation errors

### Example

**Incorrect**

```ts
// ❌ WRONG: Using type assertions
interface User {
  id: string;
  name: string;
  email: string;
  age: number;
}

const fetchUser = async (id: string): Promise<User> => {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return data as User; // DANGEROUS: No runtime validation!
};
```

**Correct**

```ts
/ ✅ RIGHT: Using Zod for validation
import { z } from 'zod';

// Define the schema
const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive().min(13),
});

// Derive the type from the schema
type User = z.infer<typeof UserSchema>;

const fetchUser = async (id: string): Promise<User> => {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();

  // Runtime validation
  return UserSchema.parse(data);
};

// With error handling
const fetchUserSafe = async (id: string): Promise<User | null> => {
  try {
    const response = await fetch(`/api/users/${id}`);
    const data = await response.json();

    const result = UserSchema.safeParse(data);
    if (!result.success) {
      console.error('Invalid user data:', result.error.format());
      return null;
    }

    return result.data;
  } catch (error) {
    console.error('Error fetching user:', error);
    return null;
  }
};
```
