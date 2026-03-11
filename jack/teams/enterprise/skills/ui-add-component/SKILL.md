# Add Component

Scaffold a Vue component with its type definition following the established blocks pattern.

## Execution

1. Determine the component purpose and props
2. Create the type definition
3. Create the component
4. Register if needed

## File Structure

Every component produces two files:

```
app/components/ComponentName.vue    — the component
app/types/component-name.ts         — the type definition
```

## Type Definition Pattern

Follow `layers/blocks/app/types/button.ts`:

```typescript
export type ComponentNameProps = {
  label?: string;
  variant?: "default" | "outline" | "ghost";
  disabled?: boolean;
};

export type ComponentNameEmits = {};

export const defineComponentName = useComponentRecipe<
  ComponentNameProps,
  ComponentNameEmits & MouseEvents & FocusEvents
>();
```

Rules:
- Props type is always `ComponentNameProps`
- Emits type is always `ComponentNameEmits` (even if empty)
- Use `useComponentRecipe()` to compose event types
- Compose standard event types: `MouseEvents`, `FocusEvents` as needed

## Component Pattern

Follow `layers/blocks/app/components/Button.vue`:

```vue
<script setup lang="ts">
import type { ComponentNameProps } from "../types/component-name";

const {
  label,
  variant = "default",
  disabled,
} = defineProps<ComponentNameProps>();
</script>

<template>
  <div>
    <!-- semantic HTML, consume design tokens -->
  </div>
</template>
```

Rules:
- Import props type from the type file
- Destructure props with defaults in setup
- Use `defineProps<T>()` with strict TypeScript
- Use semantic HTML elements
- Consume design tokens via `var(--sys-*)` — never hardcode colours or spacing
- Use Reka UI `Primitive` components for accessible primitives where appropriate

## Design System Integration

- Use `var(--sys-surface)`, `var(--sys-primary)` etc. for semantic colours
- Use `var(--ref-font-sans)`, `var(--ref-spacing-md)` for reference values
- If a needed token doesn't exist, message Uhura — do not invent tokens

## Workspace Context

Know where the component lives:
- `layers/blocks/` — foundational, consumed by all templates
- `templates/appula/` — app-specific components
- `templates/docula/` — docs-specific components
- `sites/*/` — site-specific components

Components in lower layers must be more generic. Components in sites can be specific.
