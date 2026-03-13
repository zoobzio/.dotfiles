# Review Checklist

## Phase 1: Prepare

- [ ] Task board received from briefing
- [ ] Recon understanding carried forward
- [ ] Sync with review partner — compare recon notes, confirm shared understanding
- [ ] Task order and priority understood

## Phase 2: Work the Board

For each task on the board, in order:

### Primary Reviewer Executes
- [ ] Read the relevant sub-file for this domain
- [ ] Work through every domain section in the sub-file
- [ ] For each finding, ask the domain's core question before recording
- [ ] Record findings with correct prefix, severity, location, and evidence

### Cross-Validator Reviews
- [ ] Validator reads each finding from their domain perspective
- [ ] Confirms, challenges, or acknowledges outside their domain
- [ ] Findings adjusted based on cross-validation

### Stream to Armitage
- [ ] Cross-validated findings sent to Armitage via SendMessage
- [ ] Finding includes prefix, severity, file, line range, description, impact, evidence, recommendation
- [ ] Task marked complete on board after all findings sent

## Phase 3: Architecture Domain

- [ ] Read review/architecture.md
- [ ] Read MISSION.md for stated purpose
- [ ] Read PHILOSOPHY.md for composition model
- [ ] Interface design reviewed — method count, abstraction levels, context usage
- [ ] Composition model reviewed — processor/connector/value separation
- [ ] Boundary design reviewed — transformations at ingress/egress
- [ ] Dependency policy reviewed — minimal-by-default principle
- [ ] Error design reviewed — wrapping, sentinels, messages
- [ ] Type safety reviewed — any usage, type assertions, interface satisfaction
- [ ] Observability reviewed — tracing, metrics, structured logging
- [ ] Each finding asks: "What would break if this assumption were wrong?"

## Phase 4: Code Domain

- [ ] Read review/code.md
- [ ] Run `golangci-lint run ./...`
- [ ] Run `go vet ./...`
- [ ] Linter compliance reviewed — security, quality, best practices
- [ ] Naming conventions reviewed — packages, types, functions, receivers, errors
- [ ] Godoc coverage reviewed — package comments, every exported symbol
- [ ] Error handling reviewed — unchecked returns, type assertions, wrapping, chain breakage
- [ ] Context usage reviewed — I/O functions, stored in structs, production code
- [ ] Pattern consistency reviewed — constructors, error handling, interface satisfaction
- [ ] Workspace structure reviewed — go.mod, provider code, build tags, tidy module
- [ ] Each finding asks: "What would a maintainer get wrong six months from now?"

## Phase 5: Tests Domain

- [ ] Read review/tests.md
- [ ] Run `go build ./...` — stop if build fails
- [ ] Run `go test -race ./...`
- [ ] 1:1 test mapping verified — every .go file has corresponding _test.go
- [ ] testing/ directory structure reviewed — README, helpers, benchmarks, integration
- [ ] Helper conventions reviewed — build tag, t.Helper(), parameter order, domain-specific
- [ ] Test quality reviewed — assertions present, error paths exercised, not tautological
- [ ] Benchmark conventions reviewed — allocation inside loop, compiler can't optimize away, b.ReportAllocs()
- [ ] Each finding asks: "If I introduced a bug here, would any test catch it?"

## Phase 6: Coverage Domain

- [ ] Read review/coverage.md
- [ ] Run `go test -coverprofile=coverage.out ./...`
- [ ] Examine coverage report for gaps
- [ ] Flaccid tests identified — no assertions, happy path only, weak assertions, mock everything
- [ ] Priority coverage verified — public API, error handling, security-sensitive, complex logic, recently changed
- [ ] False confidence identified — lines covered without meaningful verification

## Phase 7: Documentation Domain

- [ ] Read review/docs.md
- [ ] README assessed — no false features, completeness, working examples, valid links
- [ ] Documentation directory assessed — structure, frontmatter, cross-references
- [ ] Content accuracy assessed — code matches claims, examples work, versions current
- [ ] Content completeness assessed — every public API documented, findable, pitfalls documented
- [ ] Each finding asks: "What would mislead a new user?"

## Phase 8: Report

- [ ] All board tasks complete
- [ ] All findings cross-validated
- [ ] All findings streamed to Armitage
- [ ] Board reflects current state
