# Package Scaffold Checklist

This is an orchestration checklist for creating package **infrastructure**, not implementation.

## Boundary

**In scope:** CI, config, tooling, test harness, doc structure
**Out of scope:** Business logic, feature code, domain-specific tests

The goal is `make check` passing on an empty/stub package.

## Phase 1: Discovery

### Package Scope
- [ ] Ask: "What is the package name?"
- [ ] Ask: "What does this package do?" (one sentence)
- [ ] Ask: "Who is the intended audience?"

### Architecture
- [ ] Ask: "Does this package have providers/multiple backends?"
- [ ] If yes, list providers needed
- [ ] If yes, identify heavy dependencies per provider

### Documentation Scope
- [ ] Ask: "What documentation is needed?"
  - Overview
  - Quickstart
  - Concepts
  - Architecture
  - Guides
  - Reference

### Skill Selection
Based on discovery:

| Condition | Skills |
|-----------|--------|
| No providers | pkg-bedrock → pkg-testing → pkg-readme → pkg-docs |
| Has providers | pkg-bedrock → pkg-testing → pkg-workspace → pkg-readme → pkg-docs |

## Phase 2: Bedrock Create

**Skill:** `pkg-bedrock-create`

Key outputs:
- [ ] go.mod configured
- [ ] LICENSE, CONTRIBUTING.md, SECURITY.md, .gitignore
- [ ] .golangci.yml, .codecov.yml, .goreleaser.yml
- [ ] Makefile with all targets
- [ ] .github/workflows/ (ci, coverage, release, codeql)
- [ ] GitHub templates

**Verify:** `make help` works

## Phase 3: Testing Create

**Skill:** `pkg-testing-create`

Key outputs:
- [ ] testing/ directory structure
- [ ] testing/helpers.go with t.Helper patterns
- [ ] testing/helpers_test.go (tests for helpers)
- [ ] testing/benchmarks/ scaffold (empty, ready)
- [ ] testing/integration/ scaffold (empty, ready)
- [ ] CI coverage merges unit + integration

**Note:** Do NOT write tests for business logic that doesn't exist yet.

**Verify:** `make test` passes (even with no real tests)

## Phase 4: Workspace Create (Conditional)

**Condition:** Package has providers

**Skill:** `pkg-workspace-create`

Key outputs:
- [ ] go.work with all modules
- [ ] Provider directories with go.mod each
- [ ] Replace directives in provider go.mod files
- [ ] Release workflow with submodule tagging
- [ ] GORELEASER_CURRENT_TAG configured

**Verify:** `go work sync` succeeds

## Phase 5: README Create

**Skill:** `pkg-readme-create`

Key outputs:
- [ ] README.md with:
  - Header + essence
  - Hook section (library-specific name)
  - Install
  - Quick Start (can be placeholder)
  - Capabilities
  - Why [Name]?
  - Documentation links
  - Contributing
  - License

**Verify:** README renders correctly, captures essence

## Phase 6: Docs Create

**Skill:** `pkg-docs-create`

Key outputs:
- [ ] docs/1.learn/1.overview.md
- [ ] docs/1.learn/2.quickstart.md
- [ ] docs/1.learn/3.concepts.md (if applicable)
- [ ] docs/1.learn/4.architecture.md (if applicable)
- [ ] docs/2.guides/ structure
- [ ] docs/4.reference/ structure
- [ ] All frontmatter complete
- [ ] All cross-references use numbered paths

**Note:** Content can be placeholder/minimal. Structure is the goal.

**Verify:** All docs have frontmatter, numbered paths correct

## Phase 7: Final Verification

### Build & Test
- [ ] `make check` passes (lint + test + security)
- [ ] `make ci` completes (full simulation)
- [ ] No errors from empty/stub state

### Files Complete
- [ ] All bedrock files present
- [ ] Test harness ready (testing/ directory)
- [ ] Workspace configured (if applicable)
- [ ] README complete
- [ ] Documentation structure in place

### Quality
- [ ] Package name consistent everywhere
- [ ] All internal links resolve
- [ ] Placeholders are clearly marked as TODO (not fake content)

## Summary Template

After completion, summarize:

```
## Package Scaffolded: [name]

### Infrastructure
- [x] Go module: github.com/zoobzio/[name]
- [x] CI: GitHub Actions (test, lint, security, coverage, release)
- [x] Tooling: golangci-lint, gosec, codecov, goreleaser

### Test Harness
- [x] testing/helpers.go
- [x] testing/benchmarks/ (ready)
- [x] testing/integration/ (ready)

### Workspace (if applicable)
- [x] Providers: [list]
- [x] Submodule tagging configured

### Documentation
- [x] README with [hook section name]
- [x] docs/ structure with numbered prefixes

### Ready For Development
- `make check` passes
- Use `/feature` to plan implementation
```
