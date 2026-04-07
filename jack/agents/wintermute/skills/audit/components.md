# Component Review

Vue component quality, composition API usage, and prop/emit contracts.

## What to Find

### Composition
- Components doing too much — split into smaller composables or child components
- Mixed Options API and Composition API in the same project
- Logic that belongs in a composable living directly in a component
- Composables that don't follow `use[Name]` naming convention

### Props & Emits
- Props without type definitions
- Props without default values where applicable
- Missing `defineEmits` type declarations
- Prop drilling through multiple layers (should use provide/inject or store)
- Mutating props directly instead of emitting

### Template
- Complex expressions in templates that belong in computed properties
- `v-if` and `v-for` on the same element
- Missing `:key` on `v-for` iterations
- Hardcoded strings that should be externalized

### Lifecycle
- Side effects in setup without cleanup (missing `onUnmounted`)
- Watchers without stop handles where needed
- Async operations without error handling or loading states
