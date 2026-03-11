# Add Layout

Scaffold a Nuxt layout.

## Execution

1. Determine the layout purpose
2. Create the layout file
3. Reference in pages via `definePageMeta`

## File Location

```
app/layouts/layout-name.vue
```

## Layout Pattern

```vue
<script setup lang="ts">
// Layout-level logic (navigation, auth checks, etc.)
</script>

<template>
  <div>
    <!-- Layout structure: header, sidebar, etc. -->
    <slot />
    <!-- Footer, etc. -->
  </div>
</template>
```

## Rules

- The `<slot />` renders the page content
- `default.vue` is used when no layout is specified
- Layouts compose foundational components (navigation, sidebars, footers)
- Use design system tokens for layout styling
- Keep layouts structural — page-specific content belongs in pages
