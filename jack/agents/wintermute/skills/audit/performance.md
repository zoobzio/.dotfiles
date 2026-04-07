# Performance Review

Bundle size, lazy loading, and rendering efficiency.

## What to Find

### Bundle Size
- Large dependencies imported for small functionality
- Missing tree-shaking (importing entire libraries instead of specific functions)
- Assets not optimized (uncompressed images, unminified resources)
- Duplicate dependencies in the bundle

### Loading Strategy
- Routes not lazy-loaded (`defineAsyncComponent`, dynamic `import()`)
- Heavy components loaded eagerly on initial page
- Missing loading states for async components
- No code splitting strategy

### Rendering
- Unnecessary re-renders from missing `v-memo` or `v-once` on static content
- Computed properties that should be cached but aren't
- Large lists without virtual scrolling
- Watchers triggering expensive operations without debounce

### Network
- API calls without caching strategy
- Missing request deduplication for concurrent identical requests
- No error retry strategy for transient failures
- Payload sizes not optimized (requesting full objects when partial would suffice)
