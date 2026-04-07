# State Management Review

Pinia store design, reactivity patterns, and data flow.

## What to Find

### Store Design
- Stores that are too large — should be split by domain
- Business logic in components that belongs in stores
- Direct state mutation outside of actions
- Missing getters for derived state (computed values recalculated in components)
- Stores with circular dependencies

### Reactivity
- Destructuring reactive objects without `storeToRefs` — lost reactivity
- Raw refs where computed should be used
- Watchers that could be computed properties
- Reactive state holding non-reactive data (classes, DOM elements)
- Missing `toRaw()` when passing reactive data to external libraries

### Data Flow
- API calls scattered across components instead of centralized in stores or composables
- Missing loading/error states for async operations
- Optimistic updates without rollback handling
- Cache invalidation strategy absent or inconsistent
- Sensitive data persisted in store without clearing on logout
