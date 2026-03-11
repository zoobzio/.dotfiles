# Add Store

Scaffold a Pinia store using the composition API pattern.

## Execution

1. Determine the store purpose and data shape
2. Create the store file
3. Create a composable wrapper if needed
4. Define typed interfaces

## File Location

```
app/stores/feature-name.ts          — the store
app/composables/useFeatureName.ts   — composable wrapper (optional, Sulu's domain)
```

## Store Pattern

Follow `templates/appula/app/stores/users.ts`:

```typescript
import { defineStore } from "pinia";

export const useFeatureStore = defineStore("feature", () => {
  // Source data
  const items = ref<Item[]>([]);
  const loading = ref(false);

  // Derived state
  const total = computed(() => items.value.length);

  // Actions
  async function fetch() {
    loading.value = true;
    try {
      // API call via composable or direct fetch
    } finally {
      loading.value = false;
    }
  }

  function add(item: Item) {
    items.value.push(item);
  }

  return {
    items: readonly(items),
    loading: readonly(loading),
    total,
    fetch,
    add,
  };
});
```

## Typed Interfaces

Stores compose typed interfaces to define their contract:

```typescript
export interface TableStore<T> {
  data: Ref<T[]>;
  total: Ref<number>;
  loading: Ref<boolean>;
  sortKey: Ref<keyof T | null>;
  sortDirection: Ref<"asc" | "desc">;
  sort: (key: keyof T) => void;
  page: Ref<number>;
  pageSize: Ref<number>;
  pageCount: Ref<number>;
  goToPage: (page: number) => void;
}

export interface SelectableStore<K> {
  selected: Ref<Set<K>>;
  isAllSelected: Ref<boolean>;
  toggleRow: (key: K) => void;
  toggleAll: () => void;
  clearSelection: () => void;
}
```

The store implements these interfaces. The composable wrapper returns them.

## Rules

- Always use composition API (`setup` function), not options API
- Return `readonly()` refs for state that components shouldn't mutate directly
- Actions are plain functions, not methods
- Error handling in actions — catch and handle, don't let errors propagate silently
- Loading state for async operations
- Type the store's return value against its interface contract
