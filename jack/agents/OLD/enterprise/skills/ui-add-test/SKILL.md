# Add Test

Scaffold a test file with a 1:1 relationship to a source file.

## Execution

1. Identify the source file to test
2. Create the test file in the same directory
3. Write meaningful tests that verify behaviour

## File Location

Test files are co-located with source files:

```
app/composables/useAuth.ts       → app/composables/useAuth.test.ts
app/stores/users.ts               → app/stores/users.test.ts
app/components/Button.vue         → app/components/Button.test.ts
```

## Test Pattern

```typescript
import { describe, it, expect } from "vitest";

describe("featureName", () => {
  it("should do the expected thing", () => {
    // Arrange
    const input = createInput();

    // Act
    const result = doThing(input);

    // Assert
    expect(result).toBe(expectedValue);
  });

  it("should handle edge case", () => {
    // Test edge cases, error states, boundary conditions
  });
});
```

## What Makes a Good Test

- **Tests behaviour, not implementation.** "When I call fetchUser, I get a user back" — not "fetchUser calls fetch with these headers."
- **Meaningful assertions.** Every `expect()` verifies something that matters. No `expect(true).toBe(true)`.
- **Edge cases.** Empty data, null values, error responses, loading states.
- **Independence.** Tests don't depend on each other. Each test sets up its own state.

## What Makes a Bad Test

- **No assertions.** A test that runs without error but doesn't verify anything.
- **Happy path only.** Testing that the function works when everything is perfect.
- **Implementation coupling.** Testing that a specific internal method was called.
- **Flaky setup.** Tests that depend on timing, network, or global state.

## Component Tests

For Vue components, use `@vue/test-utils`:

```typescript
import { mount } from "@vue/test-utils";
import Button from "./Button.vue";

describe("Button", () => {
  it("renders label", () => {
    const wrapper = mount(Button, {
      props: { label: "Click me" },
    });
    expect(wrapper.text()).toContain("Click me");
  });

  it("emits click event", async () => {
    const wrapper = mount(Button);
    await wrapper.trigger("click");
    expect(wrapper.emitted("click")).toHaveLength(1);
  });

  it("respects disabled state", () => {
    const wrapper = mount(Button, {
      props: { disabled: true },
    });
    expect(wrapper.attributes("disabled")).toBeDefined();
  });
});
```

## Rules

- 1:1 relationship between source and test files
- Test infrastructure (helpers, fixtures, mocks) goes in `testing/`
- Helpers must accept the test context as first parameter
- Do not test code outside your domain — if a store bug causes a component test to fail, report it to Scotty
