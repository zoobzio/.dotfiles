# Consider

Variant-specific review concerns that layer on top of the base review skill for the repo under review. Each sub-file covers the additional considerations for a specific type of codebase.

For Go repos, the base `review` skill covers fundamentals — linting, naming, errors, context, patterns, architecture, tests, coverage, docs. The Go variant sub-files add what's unique to each variant.

For Nuxt UI repos, the `audit` skill replaces the base `review` skill entirely. The UI sub-file describes what's unique to the way zoobzio builds UI applications.

Determine the repo type, then read the relevant sub-file. Every repo is exactly one variant.

## Sub-Files

| File | Variant | When |
|------|---------|------|
| api.md | Go API application | Multi-surface HTTP APIs built on sum |
| pkg.md | Go package | Standalone library consumed by other packages or applications |
| ui.md | Nuxt UI application | Frontend applications, design system layers, content sites |
