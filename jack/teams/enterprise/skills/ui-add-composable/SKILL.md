# Add Composable

Scaffold a Vue composable following established patterns.

## Execution

1. Determine the composable purpose
2. Create the composable file
3. Nuxt auto-imports from `app/composables/` — no manual registration needed

## File Location

```
app/composables/useFeatureName.ts
```

Naming convention: `use` prefix, PascalCase feature name.

## Composable Patterns

### State Composable

For shared reactive state (follows `useAuth` pattern):

```typescript
const state = ref<StateType | null>(null);

export function useFeatureName() {
  async function fetchState(): Promise<StateType | null> {
    // fetch logic
  }

  function doAction() {
    // mutation logic
  }

  return {
    state: readonly(state),
    isDerived: computed(() => /* derived value */),
    fetchState,
    doAction,
  };
}
```

Rules:
- Module-level ref for shared state (singleton across components)
- Return `readonly()` refs for state consumers shouldn't mutate directly
- Return `computed()` for derived values
- Return functions for actions

### Store Wrapper Composable

For wrapping Pinia stores (follows `useUserTable` pattern):

```typescript
export function useFeatureName(): TypedInterface {
  const store = useFeatureStore();
  return {
    ...storeToRefs(store),
    action: store.action,
  };
}
```

### Utility Composable

For reusable logic without shared state:

```typescript
export function useFeatureName(input: Ref<InputType>) {
  const result = computed(() => /* transform input */);
  return { result };
}
```

## Rules

- Auto-imported by Nuxt — no export from index file needed
- Use `useState()` when state must survive SSR hydration
- Use module-level `ref()` for client-only shared state
- Always return an object (not a single value) for destructuring
