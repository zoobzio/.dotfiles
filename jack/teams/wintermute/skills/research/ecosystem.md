# Ecosystem

Does zoobzio already have something that does this.

## Research

- **Package inventory** — Search the zoobzio workspace for packages that solve the same problem or a related one. Check module paths, package names, exported interfaces. If it exists, Case needs to know before he flags a finding about reinvention.
- **Pattern usage** — How do other zoobzio packages handle this pattern? Is there an established convention — a common interface, a shared helper, a standard approach? If the PR diverges from established patterns, that's context Case needs.
- **Cross-package dependencies** — Does the code under review depend on other zoobzio packages that handle part of this? Is there overlap? Is there a package that should be used but isn't?
- **Memory search** — Check all agent memories for prior work on the same package or pattern. Past review findings, architectural decisions, known problem areas. The dead remember everything.

## Report Format

Report back to Case with what exists, where it lives, and how the PR relates to it. If the ecosystem already solves this problem, say so and point at the package. If the ecosystem has a convention the PR breaks, say so and explain the convention. If nothing exists, say that too — absence is an answer.
