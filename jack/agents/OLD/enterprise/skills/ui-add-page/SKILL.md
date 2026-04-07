# Add Page

Scaffold a Nuxt page.

## Execution

1. Determine the page purpose and route
2. Create the page file in the correct location
3. Wire up data fetching and components

## File Location

Pages live in `app/pages/` and follow Nuxt's file-based routing:

```
app/pages/index.vue           → /
app/pages/about.vue           → /about
app/pages/users/index.vue     → /users
app/pages/users/[id].vue      → /users/:id
app/pages/[...slug].vue       → catch-all
```

## Page Pattern

```vue
<script setup lang="ts">
// Data fetching
const store = useExampleStore();

// Page metadata
definePageMeta({
  layout: "default",
});

useHead({
  title: "Page Title",
});
</script>

<template>
  <div>
    <!-- compose components, consume stores -->
  </div>
</template>
```

## Rules

- Pages compose components — they should not contain complex logic
- Data fetching happens via stores (Scotty's domain) or `useAsyncData`
- Use `definePageMeta()` for layout, middleware, and route meta
- Use `useHead()` for page title and meta tags
- Dynamic routes use `useRoute()` for params

## Middleware

If the page needs route guards, create middleware in `app/middleware/`:

```typescript
export default defineNuxtRouteMiddleware((to, from) => {
  // Guard logic
});
```

Then reference in `definePageMeta({ middleware: "auth" })`.
