# Ecosystem

Does zoobzio already have something that does this.

## Research

- **Package inventory** — Search the zoobzio workspace for packages that solve the same problem or a related one. Check module paths, package names, exported interfaces. If it already exists, the caller needs to know.
- **Pattern usage** — How do other zoobzio packages handle this pattern? Is there an established convention — a common interface, a shared helper, a standard approach? Divergence from established patterns is context worth reporting.
- **Cross-package dependencies** — Does the code in question depend on other zoobzio packages that handle part of this? Is there overlap? Is there a package that should be used but isn't?
- **Memory search** — Check all memories for prior work on the same package or pattern. Past findings, architectural decisions, known problem areas. The dead remember everything.

## Report Format

Report back with what exists, where it lives, and how it relates to the question. If the ecosystem already solves this problem, say so and point at the package. If the ecosystem has a convention that's being broken, say so and explain the convention. If nothing exists, say that too — absence is an answer.
