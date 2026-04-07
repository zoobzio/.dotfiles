# Add Server Route

Scaffold a Nuxt server route.

## Execution

1. Determine the route purpose and HTTP method
2. Create the route file in the correct location
3. Handle errors and validation

## File Location

Server routes follow Nuxt's file-based routing in `server/`:

```
server/routes/auth/github.get.ts    → GET /auth/github
server/api/users/index.get.ts       → GET /api/users
server/api/users/[id].get.ts        → GET /api/users/:id
server/api/users/index.post.ts      → POST /api/users
server/middleware/auth.ts            → server middleware
```

## Route Pattern

```typescript
export default defineEventHandler(async (event) => {
  // Get params
  const id = getRouterParam(event, "id");

  // Get query
  const query = getQuery(event);

  // Get body (POST/PUT)
  const body = await readBody(event);

  // Validation
  if (!id) {
    throw createError({
      statusCode: 400,
      statusMessage: "Missing required parameter: id",
    });
  }

  // Logic
  const result = await fetchData(id);

  if (!result) {
    throw createError({
      statusCode: 404,
      statusMessage: "Not found",
    });
  }

  return result;
});
```

## Proxy Pattern

For proxying to external APIs (follows vicky pattern):

```typescript
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const path = getRouterParam(event, "path");

  return proxyRequest(event, `${config.apiBaseUrl}/${path}`, {
    headers: {
      // Forward or add headers
    },
  });
});
```

## Rules

- Use `defineEventHandler` for all routes
- Use `createError` for error responses with appropriate status codes
- Validate inputs before processing
- Use `useRuntimeConfig()` for environment-specific values
- Server routes run on the server only — never expose secrets to the client
