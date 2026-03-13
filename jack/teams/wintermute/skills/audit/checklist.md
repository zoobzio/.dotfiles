# Audit Checklist

## Phase 1: Prepare

- [ ] Repo confirmed as Nuxt UI variant
- [ ] Task board received with audit domains assigned
- [ ] Recon understanding carried forward
- [ ] Sync with review partner — compare recon notes, confirm shared understanding

## Phase 2: Components Domain

- [ ] Read audit/components.md

### Composition
- [ ] Components are appropriately sized — not doing too much
- [ ] Logic extracted into composables where reusable
- [ ] Composable naming follows conventions
- [ ] Script setup used consistently

### Props & Emits
- [ ] Props have type definitions
- [ ] Default values provided where appropriate
- [ ] Emits declared and typed
- [ ] No prop drilling — provide/inject or composables used for deep data
- [ ] Props not mutated directly

### Template
- [ ] No complex expressions in templates — extracted to computed or methods
- [ ] v-if and v-for not on the same element
- [ ] :key present on all v-for iterations
- [ ] No hardcoded user-facing strings where i18n is expected

### Lifecycle
- [ ] Side effects cleaned up (event listeners, timers, subscriptions)
- [ ] Watchers have stop handles where needed
- [ ] Async operations handle error and loading states
- [ ] Each finding asks: "Does this component do one thing well?"

## Phase 3: TypeScript Domain

- [ ] Read audit/typescript.md

### Type Safety
- [ ] No `any` usage without justification
- [ ] No unnecessary type assertions
- [ ] No @ts-ignore or @ts-expect-error without explanation
- [ ] No implicit any from untyped parameters
- [ ] Non-null assertions justified

### Type Coverage
- [ ] Function parameters and return types defined
- [ ] Interface definitions exist for complex objects
- [ ] Props fully typed
- [ ] Event handlers typed
- [ ] Composable inputs and outputs typed

### Type Design
- [ ] Union types are appropriately narrow
- [ ] Enum vs const vs union usage is consistent
- [ ] Utility types used where appropriate
- [ ] No duplicated type definitions across files

## Phase 4: State Domain

- [ ] Read audit/state.md

### Store Design
- [ ] Stores are focused — single responsibility
- [ ] Business logic in stores or composables, not in components
- [ ] No direct state mutation bypassing store actions
- [ ] Computed getters used for derived state
- [ ] No circular dependencies between stores

### Reactivity
- [ ] Reactive objects destructured with appropriate utilities
- [ ] Computed used instead of raw refs for derived values
- [ ] Watchers not duplicating what computed would solve
- [ ] Non-reactive data not wrapped in reactive primitives

### Data Flow
- [ ] API calls centralized in stores or composables
- [ ] Loading and error states handled
- [ ] Optimistic updates handled correctly if used
- [ ] Sensitive data not persisted to local storage

## Phase 5: Styles Domain

- [ ] Read audit/styles.md

### Scoping
- [ ] Styles scoped appropriately — no unintended global leakage
- [ ] Deep selectors used sparingly and justified
- [ ] No style conflicts between components

### Consistency
- [ ] Single styling approach used consistently
- [ ] Design tokens used instead of hardcoded values
- [ ] Breakpoints use established conventions
- [ ] Spacing and sizing follow token system

### Quality
- [ ] No unused CSS
- [ ] Selectors not overly specific
- [ ] !important usage absent or justified
- [ ] Responsive design present where expected

## Phase 6: Linting Domain

- [ ] Read audit/linting.md
- [ ] Run the project linter
- [ ] Disabled rules have justification comments
- [ ] Vue-specific rules enabled and passing
- [ ] TypeScript rules enabled and passing
- [ ] Lint config consistent across the workspace
- [ ] No files excluded from linting without justification

## Phase 7: Testing Domain

- [ ] Read audit/testing.md

### Component Tests
- [ ] Test files exist for components with logic
- [ ] Tests mount components and make assertions
- [ ] User interactions tested (click, input, navigation)
- [ ] Props and emits coverage verified
- [ ] Composables tested independently where appropriate

### E2E Tests
- [ ] Critical user flows covered
- [ ] Tests not flaky — no timing-dependent assertions
- [ ] Tests not coupled to implementation details (fragile selectors)
- [ ] Error and edge case scenarios present

### Test Infrastructure
- [ ] Test utilities shared, not duplicated
- [ ] Mock setup centralized
- [ ] Test factories exist for common data shapes

## Phase 8: Accessibility Domain

- [ ] Read audit/accessibility.md

### Semantic HTML
- [ ] Semantic elements used where appropriate — not div/span for everything
- [ ] Heading hierarchy logical and complete
- [ ] Interactive elements have correct roles
- [ ] Images have alt text

### Keyboard Navigation
- [ ] Interactive elements focusable
- [ ] Focus trapped in modals and returned on close
- [ ] Tab order logical
- [ ] Custom components handle keyboard events

### ARIA
- [ ] Labels present on interactive elements
- [ ] Live regions announce dynamic content
- [ ] aria-hidden not misused
- [ ] Form inputs have associated labels

### Color & Contrast
- [ ] Contrast meets WCAG AA
- [ ] Information not conveyed by color alone
- [ ] Focus indicators visible

## Phase 9: Performance Domain

- [ ] Read audit/performance.md

### Bundle Size
- [ ] No oversized dependencies for small features
- [ ] Tree-shaking not blocked
- [ ] Assets optimized
- [ ] No duplicate dependencies in bundle

### Loading Strategy
- [ ] Routes lazy-loaded where appropriate
- [ ] Heavy components deferred
- [ ] Loading states present during async operations
- [ ] Code splitting applied where beneficial

### Rendering
- [ ] Unnecessary re-renders avoided
- [ ] Computed used over raw refs for derived values
- [ ] Large lists use virtual scrolling if appropriate
- [ ] Watchers debounced where firing frequently

### Network
- [ ] Caching strategy present for repeated requests
- [ ] Request deduplication applied where appropriate
- [ ] Error retry handled gracefully
- [ ] Payload sizes reasonable

## Phase 10: Report

- [ ] All audit domains complete
- [ ] All findings cross-validated with review partner
- [ ] All findings streamed to Armitage
- [ ] Board reflects current state
