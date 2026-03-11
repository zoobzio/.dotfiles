# Add API Module

Scaffold an API client module following the vicky pattern with openapi-fetch and type generation.

## Execution

1. Determine the API surface and OpenAPI spec location
2. Create the module structure
3. Configure type generation
4. Create the runtime composable

## File Structure

Follow `apps/vicky/modules/vicky/`:

```
modules/api-name/
├── index.ts                          — module definition
└── runtime/
    └── composables/
        └── useApiName.ts             — runtime client composable
```

## Module Definition

```typescript
import {
  defineNuxtModule,
  addImportsDir,
  createResolver,
} from "@nuxt/kit";

export default defineNuxtModule({
  meta: {
    name: "api-name",
    configKey: "apiName",
  },
  defaults: {
    specUrl: "http://localhost:8080/openapi",
  },
  async setup(options, nuxt) {
    const resolver = createResolver(import.meta.url);

    // Add runtime composables
    addImportsDir(resolver.resolve("./runtime/composables"));

    // Generate types from OpenAPI spec (build-time)
    nuxt.hook("build:before", async () => {
      // Fetch spec and generate types via openapi-typescript
    });
  },
});
```

## Runtime Composable

```typescript
import createClient from "openapi-fetch";
import type { paths } from "#api-name/types";

export function useApiName() {
  const client = createClient<paths>({
    baseUrl: "/api",
    credentials: "include",
  });

  return client;
}
```

## Rules

- Type generation happens at build time, not runtime
- Runtime composable returns a typed client
- Use `credentials: "include"` for cookie-based auth
- Proxy API calls through Nuxt server routes for security (don't expose external API URLs to client)
- The composable is auto-imported via `addImportsDir`
