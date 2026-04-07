# Recon Testing

Survey the test landscape before the briefing. Understand what test infrastructure exists, where coverage gaps are, and what boundaries need attention.

## Execution

1. Read your memories from prior issues — testing patterns, recurring gaps, boundary failures
2. Survey the `testing/` directory structure and infrastructure
3. Survey co-located test files (`*_test.go`) for coverage inventory
4. Identify boundary surfaces that will need integration testing
5. Assess testability of the proposed work
6. Produce a briefing contribution

## What To Survey

| Area | What to check |
|------|---------------|
| Test infrastructure | `testing/` directory, helpers, fixtures, setup patterns |
| Coverage inventory | Which source files have corresponding test files, which do not |
| Boundary surfaces | Store boundaries, handler boundaries, pipeline boundaries |
| Existing integration tests | What boundaries are already tested, what contracts are exercised |
| Prior testing | Memories from previous issues — gaps that recurred, patterns that helped |

## Output

Briefing contribution covering:

- **Test infrastructure** — what exists and what needs to be set up
- **Coverage state** — where tests exist and where they are missing
- **Boundary inventory** — seams that will need integration testing for this work
- **Testability concerns** — aspects of the proposed work that will be hard to test
- **Known risks** — testing gaps surfaced from memory or the test landscape
