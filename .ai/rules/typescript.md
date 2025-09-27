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

## Global Rules

Prefer identity functions for typed configuration/builders (constrain inputs, infer outputs). 
Total TypeScript

Use branded types for nominal safety at boundaries (IDs, opaque tokens, passwords). 
Total TypeScript

Write explicit type guards (val is T) and assertion functions (asserts val is T) at runtime boundaries. 
Total TypeScript

Expose chainable/builder APIs using generics + progressive inference; ensure immutable returns. (Builder/chainable approach is emphasized across the Advanced Patterns path.) 
GitHub
+1

Augment globals safely (module/global augmentation with clear namespaces) only when unavoidable. 
Total TypeScript

Classes are allowed when they improve ergonomics (encapsulation + static helpers) and preserve type-level guarantees. 
Total TypeScript

External libraries: add typed adapters (wrappers) that narrow/brand the library’s untyped or less-typed outputs. 
Total TypeScript

Use discriminated unions and exhaustive switch (never-reached checks) for control flow.

Prefer satisfies for object literals to keep inference while enforcing surface contracts.

Test first: each pattern must have at least one failing → passing test case.

## Pattern Playbook

1. **Identity Function (constrained builder)**

* Prefer defineX identity functions over factory functions with wide types.
* Constrain generics early to produce precise inference in the return type.

You are generating a typed builder using the identity function pattern.
Requirements:
- Use a <T extends ...> constrained generic; return the input config without widening.
- Each step must strengthen inference (no 'any' or broad unions unless justified).
- Include minimal runtime checks if inputs can be invalid.
- Provide a 2–3 test cases that prove inference (expectTypeOf or dtslint-style).
Follow the rules in typescript.md.

```ts
type Route = { method: 'GET' | 'POST'; path: string };

const defineRoute = <M extends Route['method'], P extends string>(config: {
  method: M;
  path: P;
}) => config;

const getUser = defineRoute({ method: 'GET', path: '/users/:id' });
// ^ typed as { method: "GET"; path: "/users/:id" }
```

2. **Branded (opaque/nominal) types**  
   - Use branded types for domain-specific identifiers, opaque tokens, or any concept where you want to enforce type distinction at compile time. :contentReference[oaicite:1]{index=1}  
   - Always brand at boundaries: when converting from raw/untrusted data into your domain. Pass brands through internally.

    Create a boundary module for an opaque identifier using branded types.
  - Define Brand<T, Name> helper and a creator (after validating input).
  - Demonstrate compile-time rejection of unbranded strings.
  - Include a thin runtime validator + one assertion function.

```ts
  type Brand<T, B extends string> = T & { readonly __brand: B };

  type UserId = Brand<string, 'UserId'>;

  const asUserId = (v: string) => v as UserId; // only at boundary
  function loadUser(id: UserId) { /* ... */ }
```

3. **Type predicates & assertion guards**

    Write small, composable type guards and one assertion function for the given schema.

    - Prefer narrow primitive checks; compose guards.
    - Show usage narrowing unknown → DomainType.
    - Include tests with good and bad payloads.
    - Validate all external or untyped inputs (JSON, environment variables, HTTP request bodies, external libraries) using predicates (`x is T`) or assertion functions (`asserts x is T`). :contentReference[oaicite:2]{index=2}  
    - Build small, reusable guards and compose them. E.g., `isNonEmptyString`, `isValidEmail`, then assemble.

```ts
type User = { id: string; name: string };

export function isUser(x: unknown): x is User {
  return !!x && typeof (x as any).id === 'string' && typeof (x as any).name === 'string';
}

export function assertUser(x: unknown): asserts x is User {
  if (!isUser(x)) throw new Error('Not a User');
}
```

4. **Chainable / Builder APIs with progressive typing**
    Design a chainable configuration builder.
    - Each chained call refines the generic type parameters; no mutation.
    - Return new objects per step; preserve inference across steps.
    - Add an end() method that returns the fully inferred config type.
    - For configuration builders or staged APIs: each chained method should refine types (add more information) rather than widen.  
    - Builder steps should return *new objects*, avoid mutating internal state in ways that degrade type inference.

```ts
type Config<S, P> = { state: S; plugins: P[] };

const builder = <S>() => ({
  withState<T extends S>(state: T) {
    return {
      withPlugin<P>(p: P) {
        return builder<T & {}>().withState(state) as Config<T, [P]>;
      },
    };
  },
});
```

5. **Safe global/module augmentation**
    Wrap the external library 'X' with a typed facade.

    - Narrow/validate all outputs (guards or zod), brand critical IDs.
    - No untyped responses leak out; prove via exported types.
    - Include a negative test where invalid data is rejected.
    - If using `declare global` or augmenting existing global interfaces, isolate such augmentations behind typed accessors/helpers.  
    - Be careful about name collisions; use clear prefixes.

```ts
declare global {
  interface Window {
    __APP_ENV?: 'dev' | 'prod';
  }
}
// Access only through a typed accessor:
export const getEnv = () => window.__APP_ENV ?? 'dev';
```

6. **Classes with invariants**
    Implement a small value-object class with invariants.
    - Private constructor; static factory; no public mutable fields.
    - Methods return new instances; no mutation.
    - Add tests: invariant holds; misuse is rejected at compile-time.
    - Use `private` (or `protected`) constructors + `static` factory methods to enforce invariants.  
    - Public methods should not allow breaking invariants. Methods returning new instances rather than mutating internal state (if needed for safety).

7. **Adapters / facades for external libraries**  
   - When working with untyped or weakly typed external libs, wrap their outputs in validation/guards/brands before exposing them.  
   - Prevent unvalidated/untyped data from leaking into your application domain.

```ts
import * as lib from 'some-lib';

type SafeThing = { id: string };
const isSafeThing = (x: unknown): x is SafeThing => !!x && typeof (x as any).id === 'string';

export async function getThing(id: string) {
  const raw = await lib.fetchThing(id);
  if (!isSafeThing(raw)) throw new Error('Bad shape from lib');
  return raw; // now SafeThing
}
```

8. **Discriminated unions & exhaustive control flow**  
   - Use discriminated unions for variants/cases; ensure `switch` or other branching is exhaustive (e.g. using `never` for unreachable cases).  

9. **Type assertion of objects with `satisfies`**  
   - Use `satisfies` for literal / object definitions to ensure they meet contract without losing inference.  

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
- Include tests that assert type inference, for example via `expectTypeOf`, `ts-dts`, or `@ts-expect-error` annotations.  
- Always include at least one negative test (that incorrect usage fails at compile time).

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
