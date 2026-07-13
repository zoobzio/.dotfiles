---
name: assess
description: Adversarial code assessment — architecture, code quality, tests, coverage, docs. Domain checklists for what to look for during PR review of Go repositories.
user-invocable: false
allowed-tools: Read, Grep, Glob, Bash
---

# Assess

Adversarial assessment organized by domain. Each sub-file covers one review topic — run the sub-file relevant to the work at hand.

Read the relevant sub-file for the domain being reviewed. Do not read all sub-files unless instructed.

## Sub-Files

| File | Domain | Finding Prefix |
|------|--------|---------------|
| architecture.md | Structural weakness, interface design, composition, boundaries | ARC |
| code.md | Code quality, patterns, naming, linting, workspace | COD |
| coverage.md | Test coverage quality, flaccid tests, undefended paths | COV |
| docs.md | Documentation accuracy, completeness, structure | DOC |
| tests.md | Test quality, infrastructure, benchmarks, helpers | TST |
