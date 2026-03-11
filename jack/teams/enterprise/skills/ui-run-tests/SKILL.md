# Run Tests

Execute the test suite and report results.

## Execution

1. Run the appropriate test command
2. Analyse results
3. Report failures with context

## Commands

### Full Suite
```bash
pnpm test
```

### Specific Workspace
```bash
pnpm --filter @foundation/blocks test
pnpm --filter @zoobz/vicky test
```

### Specific File
```bash
pnpm vitest run app/composables/useAuth.test.ts
```

### Watch Mode (development)
```bash
pnpm vitest watch
```

## Reporting

When tests fail, report:

- Which test failed (file, describe block, test name)
- What was expected vs. what happened
- The relevant source code context
- Whether this is a source code bug or a test bug

Message the relevant builder (Sulu, Scotty, or Uhura) with the failure details. Include reproduction steps.

## Rules

- Run the full suite before reporting "all tests pass"
- Don't just report pass/fail — analyse failures
- A test failure in one domain may be caused by a bug in another domain. Investigate before reporting.
- If the test infrastructure itself is broken (vitest config, missing dependencies), escalate to Spock
