# Tanstack Start

## Documentation

1. **Routing**: https://tanstack.com/start/latest/docs/framework/react/guide/routing
2. **Execution Model**: https://tanstack.com/start/latest/docs/framework/react/guide/execution-model
3. **Execution Patterns**: https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns
4. **Server Functions**: https://tanstack.com/start/latest/docs/framework/react/guide/server-functions
5. **Server Routes**: https://tanstack.com/start/latest/docs/framework/react/guide/server-routes
6. **Middleware**: https://tanstack.com/start/latest/docs/framework/react/guide/middleware
7. **Env**: https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables
8. **Server Entry Point**: https://tanstack.com/start/latest/docs/framework/react/guide/server-entry-point
9. **ISR**: https://tanstack.com/start/latest/docs/framework/react/guide/isr
10. **SPA Mode**: https://tanstack.com/start/latest/docs/framework/react/guide/spa-mode
11. **Selective SSR**: https://tanstack.com/start/latest/docs/framework/react/guide/selective-ssr
12. **Hydration Errors**: https://tanstack.com/start/latest/docs/framework/react/guide/hydration-errors
13. **Client Entry Point**: https://tanstack.com/start/latest/docs/framework/react/guide/client-entry-point

## Integration Patterns

Quick reference for common full-stack flows. Each flow has a dedicated file with complete copy-paste examples.

### Flow Overview

| Flow                                               | Components                       | Use Case                      |
| -------------------------------------------------- | -------------------------------- | ----------------------------- |
| [Suspense Query + Loader](#suspense-query--loader) | useSuspenseQuery, Router, Loader | SSR-ready data fetching       |
| [Form → Server → Query](#form--server--query)      | Form, Server Function, Query     | Create/update resources       |
| [Infinite List](#infinite-list)                    | Infinite Query, Server Function  | Paginated feeds, timelines    |
| [Paginated Table](#paginated-table)                | Table, Query, Router Search      | Admin dashboards, data grids  |
| [Auth → Protected Route](#auth--protected-route)   | Auth Client, Middleware, Router  | Login, session, guards        |
| [Error Handling](#error-handling)                  | Error Boundaries, Toast          | Error recovery, user feedback |

### Suspense Query + Loader

The preferred pattern for SSR-ready data fetching: use `useSuspenseQuery` with route loaders to ensure data is ready before render.

**Key pieces:**

```tsx
// 1. Query options hook (apps/web/src/modules/posts/hooks/use-posts-options.ts)
import { queryOptions } from '@tanstack/react-query';
import { getPosts } from '../server/get-posts';

export function postsOptions() {
  return queryOptions({
    queryKey: ['posts'],
    queryFn: () => getPosts(),
    staleTime: 1000 * 60, // 1 minute
  });
}

export function postOptions(id: string) {
  return queryOptions({
    queryKey: ['posts', id],
    queryFn: () => getPost({ data: { id } }),
    staleTime: 1000 * 60,
  });
}

// 2. Route with loader ensures data is cached before render
export const Route = createFileRoute('/_app/posts')({
  loader: async ({ context }) => {
    await context.queryClient.ensureQueryData(postsOptions());
  },
  component: PostsPage,
});

// 3. Component uses useSuspenseQuery - data is guaranteed
import { useSuspenseQuery } from '@tanstack/react-query';

function PostsPage() {
  const { data: posts } = useSuspenseQuery(postsOptions());
  // posts is always defined - no loading state needed here
  return <PostList posts={posts} />;
}
```

**With route params:**

```tsx
// Route with dynamic param
export const Route = createFileRoute('/_app/posts/$id')({
  loader: async ({ context, params }) => {
    await context.queryClient.ensureQueryData(postOptions(params.id));
  },
  component: PostPage,
});

function PostPage() {
  const { id } = Route.useParams();
  const { data: post } = useSuspenseQuery(postOptions(id));
  return <PostDetail post={post} />;
}
```

**With beforeLoad for auth + data:**

```tsx
export const Route = createFileRoute('/_app/dashboard')({
  beforeLoad: async ({ context }) => {
    const session = await auth.api.getSession({
      headers: context.request.headers,
    });
    if (!session) throw redirect({ to: '/login' });
    return { user: session.user };
  },
  loader: async ({ context }) => {
    // User is guaranteed to exist after beforeLoad
    await context.queryClient.ensureQueryData(dashboardOptions());
  },
  component: DashboardPage,
});

function DashboardPage() {
  const { user } = Route.useRouteContext();
  const { data } = useSuspenseQuery(dashboardOptions());
  return <Dashboard user={user} data={data} />;
}
```

**Pattern summary:**

| Step          | Purpose                                  | Location            |
| ------------- | ---------------------------------------- | ------------------- |
| `beforeLoad`  | Auth guards, redirect, inject context    | Route definition    |
| `loader`      | Ensure query data is cached (SSR-ready)  | Route definition    |
| Query options | Define queryKey, queryFn, staleTime      | Module hooks folder |
| Component     | Use `useSuspenseQuery` with same options | Route component     |

---

### Form → Server → Query

Creates a resource with validation, server mutation, and cache invalidation.

**Key pieces:**

```tsx
import { createServerFn } from '@tanstack/react-start';
import { db } from '@oakoss/database';
import { auth } from '@oakoss/auth/server';

// 1. Server function with auth + validation
export const createPost = createServerFn({ method: 'POST' })
  .inputValidator(createPostSchema)
  .handler(async ({ data, request }) => {
    const session = await auth.api.getSession({ headers: request.headers });
    if (!session) return { error: 'Unauthorized', code: 'AUTH_REQUIRED' };
    // ... insert and return
  });

// 2. Form with mutation
const mutation = useMutation({
  mutationFn: (values) => createPost({ data: values }),
  onSuccess: (result) => {
    if (result.success) {
      queryClient.invalidateQueries({ queryKey: ['posts'] });
      toast.success('Created!');
    }
  },
});

// 3. Handle server errors in form
if (result.error) {
  form.setErrorMap({ onServer: result.error });
}
```

---

## Infinite List

Cursor-based pagination with intersection observer auto-loading.

**Key pieces:**

```tsx
import { createServerFn } from '@tanstack/react-start';
import { db, lt } from '@oakoss/database';
import { posts } from '@oakoss/database/schema';

// 1. Server function returns { items, nextCursor }
export const getPostsInfinite = createServerFn({ method: 'GET' })
  .inputValidator(
    z.object({ cursor: z.string().optional(), limit: z.number() }),
  )
  .handler(async ({ data }) => {
    const items = await db.query.posts.findMany({
      where: data.cursor
        ? lt(posts.createdAt, new Date(data.cursor))
        : undefined,
      limit: data.limit + 1,
    });
    const hasMore = items.length > data.limit;
    return {
      items: hasMore ? items.slice(0, -1) : items,
      nextCursor: hasMore ? items.at(-1)?.createdAt.toISOString() : undefined,
    };
  });

// 2. Infinite query options
export function postsInfiniteOptions() {
  return {
    queryKey: ['posts', 'infinite'],
    queryFn: ({ pageParam }) =>
      getPostsInfinite({ data: { cursor: pageParam } }),
    initialPageParam: undefined,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
  };
}

// 3. Auto-fetch on scroll
const { ref, inView } = useInView();
useEffect(() => {
  if (inView && hasNextPage) fetchNextPage();
}, [inView, hasNextPage]);
```

---

### Paginated Table

Server-side pagination with URL state synchronization.

**Key pieces:**

```tsx
import { zodValidator } from '@tanstack/zod-adapter';

// 1. Route validates search params
export const Route = createFileRoute('/_app/admin/users')({
  validateSearch: zodValidator(
    z.object({
      page: z.number().default(1),
      size: z.number().default(10),
      sort: z.enum(['name', 'email', 'createdAt']).default('createdAt'),
    }),
  ),
  loaderDeps: ({ search }) => search,
  loader: ({ context, deps }) =>
    context.queryClient.ensureQueryData(usersQueryOptions(deps)),
});

// 2. Update URL on table state change
const handlePaginationChange = (pagination: PaginationState) => {
  navigate({
    search: (prev) => ({
      ...prev,
      page: pagination.pageIndex + 1,
      size: pagination.pageSize,
    }),
  });
};

// 3. Server function returns { items, meta: { total, totalPages } }
```

---

### Auth → Protected Route

Login flow with session and route protection.

**Key pieces:**

```tsx
import { authClient } from '@oakoss/auth/client';
import { auth } from '@oakoss/auth/server';
import { createMiddleware } from '@tanstack/react-start';

// 1. Login with Better Auth client
const result = await authClient.signIn.email({ email, password });
if (result.error) form.setErrorMap({ onServer: result.error.message });

// 2. Auth middleware
export const authMiddleware = createMiddleware().server(
  async ({ request, next }) => {
    const session = await auth.api.getSession({ headers: request.headers });
    if (!session) throw redirect({ to: '/login' });
    return next({ context: { session } });
  },
);

// 3. Protected layout applies middleware
export const Route = createFileRoute('/_app')({
  server: { middleware: [authMiddleware] },
  component: AppLayout,
});

// 4. Access session in components
const { session } = Route.useRouteContext();
```

---

### Error Handling

Structured errors with boundaries and recovery.

**Key pieces:**

```tsx
import { Button } from '@oakoss/ui';

// 1. Return structured errors from server
return { error: 'Not found', code: 'NOT_FOUND' };

// 2. Handle in mutation onSuccess
if ('error' in result) {
  switch (result.code) {
    case 'AUTH_REQUIRED':
      navigate({ to: '/login' });
      break;
    case 'VALIDATION_ERROR':
      form.setFieldMeta(...);
      break;
    default:
      toast.error(result.error);
  }
}

// 3. Route error boundaries
export const Route = createFileRoute('...')({
  errorComponent: ({ error, reset }) => (
    <div>
      <p>{error.message}</p>
      <Button onPress={reset}>Try Again</Button>
    </div>
  ),
  notFoundComponent: () => <NotFoundMessage />,
});
```

---

## Common Mistakes

| Mistake                                              | Correct Pattern                                                   |
| ---------------------------------------------------- | ----------------------------------------------------------------- |
| Using `useQuery` without loader                      | Use `useSuspenseQuery` + `ensureQueryData` in loader for SSR      |
| Checking `isPending` in Suspense components          | `useSuspenseQuery` guarantees data - no pending state             |
| Hooks in wrong location                              | Package hooks → module hooks → global hooks (see placement guide) |
| Duplicating query options                            | Create options hook once, reuse in loader and component           |
| Not invalidating cache after mutation                | Use `queryClient.invalidateQueries({ queryKey })` in onSuccess    |
| Missing auth check in server function                | Always verify session from `request.headers`                      |
| Form not showing server errors                       | Use `form.setErrorMap({ onServer: error })`                       |
| Infinite query without proper cursor                 | Provide `initialPageParam` and `getNextPageParam`                 |
| Not prefetching for SSR                              | Use `ensureQueryData` in route loaders                            |
| Table state not synced to URL                        | Use `validateSearch` + navigate on change                         |
| Handling error in onError instead of checking result | Server functions return errors in result, not thrown              |
| Not resetting page on filter change                  | Set `page: 1` when search/filter changes                          |
| Missing loading states                               | Show skeletons during `isPending`, overlays during `isFetching`   |
| No error boundary on routes                          | Add `errorComponent` and `notFoundComponent`                      |

---

## Delegation

- **Pattern discovery**: For finding existing implementations, use `Explore` agent
- **Code review**: After implementing flows, delegate to `code-reviewer` agent
- **Security audit**: For auth flows, delegate to `security-auditor` agent

TanStack Router provides built-in error handling:

```tsx
import { Button } from '@oakoss/ui';

export const Route = createFileRoute('/posts/$id')({
  errorComponent: ({ error, reset }) => (
    <div className="p-4">
      <h2>Something went wrong</h2>
      <p>{error.message}</p>
      <Button onPress={reset}>Try again</Button>
    </div>
  ),
});
```

## Error Component Types

| Level     | Component               | Use Case                |
| --------- | ----------------------- | ----------------------- |
| Route     | `errorComponent`        | Route-specific errors   |
| Global    | `defaultErrorComponent` | Fallback for all routes |
| Not Found | `notFoundComponent`     | 404 errors              |

## Route-Level Error Boundary

```tsx
import { Button } from '@oakoss/ui';
import { AlertCircle } from 'lucide-react';

export const Route = createFileRoute('/dashboard')({
  component: DashboardComponent,
  errorComponent: DashboardError,
  pendingComponent: DashboardLoading,
});

function DashboardError({ error, reset }: ErrorComponentProps) {
  return (
    <div className="flex flex-col items-center gap-4 p-8">
      <AlertCircle className="size-12 text-destructive" />
      <h2 className="text-lg font-semibold">Failed to load dashboard</h2>
      <p className="text-muted-foreground">{error.message}</p>
      <Button onPress={reset}>Retry</Button>
    </div>
  );
}
```

## Global Error Boundary

Configure in router setup:

```tsx
// apps/web/src/router.tsx
import { GlobalError } from '@/components/errors/global-error';
import { NotFoundError } from '@/components/errors/not-found-error';

export const getRouter = () =>
  createRouter({
    routeTree,
    defaultErrorComponent: GlobalError,
    defaultNotFoundComponent: NotFoundError,
  });
```

## Error Component Props

```ts
type ErrorComponentProps = {
  error: Error; // The caught error
  reset: () => void; // Retry the operation
  info?: { componentStack: string }; // React error info
};
```

## Fallback UI Patterns

### Minimal Fallback

```tsx
function MinimalError({ error, reset }: ErrorComponentProps) {
  return (
    <div className="p-4 text-center">
      <p>Something went wrong.</p>
      <Button variant="link" onPress={reset}>
        Try again
      </Button>
    </div>
  );
}
```

### Detailed Fallback

```tsx
import { Card, CardHeader, CardContent, CardFooter, Button } from '@oakoss/ui';
import { AlertTriangle } from 'lucide-react';

function DetailedError({ error, reset }: ErrorComponentProps) {
  return (
    <Card className="mx-auto max-w-md">
      <CardHeader>
        <h2 className="flex items-center gap-2 text-lg font-semibold">
          <AlertTriangle className="text-destructive" />
          Error
        </h2>
      </CardHeader>
      <CardContent>
        <p className="text-muted-foreground">{error.message}</p>
        {process.env.NODE_ENV === 'development' && (
          <pre className="mt-4 overflow-auto rounded bg-muted p-2 text-xs">
            {error.stack}
          </pre>
        )}
      </CardContent>
      <CardFooter className="gap-2">
        <Button onPress={reset}>Retry</Button>
        <Button variant="secondary" onPress={() => window.location.reload()}>
          Reload page
        </Button>
      </CardFooter>
    </Card>
  );
}
```

## Not Found Component

```tsx
import { notFound, Link } from '@tanstack/react-router';
import { Button } from '@oakoss/ui';

export const Route = createFileRoute('/posts/$id')({
  loader: async ({ params }) => {
    const post = await getPost(params.id);
    if (!post) throw notFound();
    return post;
  },
  notFoundComponent: () => (
    <div className="p-8 text-center">
      <h2 className="text-xl font-semibold">Post not found</h2>
      <p className="text-muted-foreground">
        The post you're looking for doesn't exist.
      </p>
      <Button className="mt-4" asChild>
        <Link to="/posts">Back to posts</Link>
      </Button>
    </div>
  ),
});
```

## Triggering Not Found

```tsx
import { notFound } from '@tanstack/react-router';

// In loader
export const Route = createFileRoute('/posts/$id')({
  loader: async ({ params }) => {
    const post = await getPost(params.id);
    if (!post) throw notFound();
    return post;
  },
});

// In component
function PostContent() {
  const post = Route.useLoaderData();
  if (!post.published) throw notFound();
  return <article>...</article>;
}
```

## Common Mistakes

| Mistake                       | Correct Pattern                           |
| ----------------------------- | ----------------------------------------- |
| Not providing reset function  | Always include retry/reset button         |
| Catching errors in component  | Let errors bubble to boundary             |
| Missing route error component | Add `errorComponent` to routes            |
| Not logging errors            | Log to console and/or external service    |
| Showing stack trace in prod   | Only show in `NODE_ENV === 'development'` |
| Generic error message         | Show context-specific messages            |
| Missing notFoundComponent     | Handle 404s at route level                |
| Swallowing async errors       | Use error boundaries with Suspense        |
| No reload/escape option       | Provide "Reload page" fallback button     |
| Not handling loader errors    | Loader errors need `errorComponent` too   |

## Delegation

- **Error logging**: For monitoring, consider external services
- **Code review**: After creating error components, delegate to `code-reviewer` agent
