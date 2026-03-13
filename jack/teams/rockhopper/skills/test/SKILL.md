# Test

The testing playbook. Read the specific sub-file when a situation calls for it. Do not load all sub-files upfront.

| Task | File | When to Read |
|------|------|--------------|
| Recon | `recon.md` | Before writing any tests — survey what exists, what's missing, what's lying |
| Unit Tests | `unit.md` | When writing unit tests for a source file |
| Integration Tests | `integration.md` | When writing tests that span components or depend on external services |
| Benchmarks | `benchmark.md` | When writing performance benchmarks for hot paths |
| Helpers | `helper.md` | When writing consumer-facing test helpers |
