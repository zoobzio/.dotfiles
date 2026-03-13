# Test Review

Component testing, E2E testing, and test quality for Nuxt applications.

## What to Find

### Component Tests
- Missing test files for components with logic
- Tests that mount components without asserting behavior
- Missing user interaction tests (click, input, submit)
- Props/emits not tested
- Composables tested only through components instead of in isolation

### E2E Tests
- Critical user flows without E2E coverage
- Flaky tests from timing issues (missing `waitFor`, hard `sleep`)
- Tests coupled to implementation details (selectors on class names instead of data-testid)
- Missing error state and edge case scenarios

### Snapshot Tests
- Snapshots of entire pages — too brittle, break on any change
- Outdated snapshots committed without review
- Snapshots used where assertion-based tests would be clearer

### Test Infrastructure
- Missing test utilities or helpers for common patterns
- Mock setup duplicated across test files
- Test data factories absent — each test builds its own fixtures
- No CI integration for test execution
