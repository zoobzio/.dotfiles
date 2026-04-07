---
name: verify
description: Unit testing — prove that each piece does what it claims
---

# Verify

Testing individual components. Each sub-file covers a specific unit testing concern — read the one that matches what you are testing.

| Concern | File | When to Read |
|---------|------|-------------|
| Test infrastructure | `setup.md` | Setting up unit test infrastructure — fixtures, mocks, helpers |
| Unit test patterns | `units.md` | Writing unit tests for handlers, stores, transformers, models |
| Coverage analysis | `coverage.md` | Analysing test coverage quality, detecting flaccid tests |
| Fixtures and mocks | `fixtures.md` | Creating test data, mock implementations, and test helpers |

Do not load all sub-files upfront. Read the specific sub-file when the current test requires that concern.
