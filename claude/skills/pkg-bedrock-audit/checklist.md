# Bedrock Audit Checklist

## Phase 1: Inventory

### File Presence
- [ ] `go.mod` exists
- [ ] `LICENSE` exists
- [ ] `CONTRIBUTING.md` exists
- [ ] `SECURITY.md` exists
- [ ] `.gitignore` exists
- [ ] `Makefile` exists
- [ ] `.golangci.yml` exists
- [ ] `.codecov.yml` exists
- [ ] `.goreleaser.yml` exists
- [ ] `.github/workflows/ci.yml` exists
- [ ] `.github/workflows/coverage.yml` exists
- [ ] `.github/workflows/release.yml` exists
- [ ] `.github/workflows/codeql.yml` exists
- [ ] `testing/` directory exists

## Phase 2: Go Module Assessment

- [ ] Module path follows `github.com/zoobzio/[package]` convention
- [ ] Go version is 1.24 or higher
- [ ] Toolchain directive present (`toolchain go1.25.x`)
- [ ] No unnecessary dependencies
- [ ] `go mod tidy` produces no changes

## Phase 3: Repository Files Assessment

### LICENSE
- [ ] MIT License format
- [ ] Correct year
- [ ] Correct copyright holder

### CONTRIBUTING.md
- [ ] Links to `make help` or documents available commands
- [ ] Explains fork/clone/branch workflow
- [ ] Lists prerequisites (Go version, tools)
- [ ] Describes commit message format
- [ ] Mentions coverage expectations

### SECURITY.md
- [ ] Vulnerability reporting instructions present
- [ ] Contact method specified

### .gitignore
- [ ] Binaries (*.exe, *.dll, *.so, *.dylib)
- [ ] Test files (*.test, *.out, coverage.*)
- [ ] IDE files (.idea/, .vscode/, *.swp)
- [ ] OS files (.DS_Store, Thumbs.db)
- [ ] Build artifacts (dist/, vendor/)

### GitHub Templates (Removal Targets)
- [ ] `.github/PULL_REQUEST_TEMPLATE.md` does NOT exist (remove if present)
- [ ] `.github/ISSUE_TEMPLATE/` does NOT exist (remove if present)

CI enforces quality; templates add friction without value.

## Phase 4: Tooling Configuration Assessment

### .golangci.yml

Version & Settings:
- [ ] Version is `"2"`
- [ ] run.timeout is 5m
- [ ] run.tests is true

Required Linters:
- [ ] gosec enabled
- [ ] errorlint enabled
- [ ] govet enabled
- [ ] staticcheck enabled
- [ ] errcheck enabled

Recommended Linters:
- [ ] noctx, bodyclose, sqlclosecheck (security)
- [ ] gocritic, revive (best practices)
- [ ] dupl, goconst, misspell (code quality)

Settings:
- [ ] errcheck.check-type-assertions: true
- [ ] govet.enable-all: true
- [ ] dupl.threshold: 150
- [ ] goconst.min-len: 3, min-occurrences: 3
- [ ] Test file exclusions configured

### .codecov.yml
- [ ] Project target: 70%
- [ ] Project threshold: 1%
- [ ] Patch target: 80%
- [ ] Ignore patterns include *_test.go, docs/, .github/
- [ ] PR comment configuration present

### .goreleaser.yml
- [ ] Version is 2
- [ ] builds.skip: true (for library packages)
- [ ] Changelog configured with conventional commit groups
- [ ] Excludes docs:, test: from changelog
- [ ] Release header includes installation instructions

## Phase 5: Makefile Assessment

### Required Targets
- [ ] `help` — Self-documenting
- [ ] `test` — All tests with race detector
- [ ] `test-unit` — Short mode
- [ ] `test-integration` — Integration tests
- [ ] `test-bench` — Benchmarks
- [ ] `lint` — golangci-lint
- [ ] `lint-fix` — Auto-fix
- [ ] `coverage` — HTML report
- [ ] `clean` — Remove generated files
- [ ] `check` — test + lint
- [ ] `ci` — Full simulation
- [ ] `install-tools` — golangci-lint installation
- [ ] `install-hooks` — Git hooks

### Conventions
- [ ] `.PHONY` declaration present
- [ ] `.DEFAULT_GOAL := help`
- [ ] Uses `-race` flag for tests
- [ ] Uses `-tags testing` for test targets

### Verification
- [ ] `make help` works
- [ ] `make check` runs successfully
- [ ] Targets use consistent flags with CI

## Phase 6: CI Workflows Assessment

### ci.yml
- [ ] Triggers on push to main and pull_request
- [ ] Test job with Go matrix (1.24, 1.25)
- [ ] Lint job uses golangci-lint-action@v7
- [ ] Security job with gosec and SARIF upload
- [ ] Benchmark job with artifact upload
- [ ] ci-complete aggregation job
- [ ] Uses Makefile targets where possible

### coverage.yml
- [ ] Triggers on push and pull_request
- [ ] Uses Codecov action with token
- [ ] Generates PR comments with coverage metrics
- [ ] Coverage summary in GITHUB_STEP_SUMMARY
- [ ] Artifacts uploaded

### release.yml
- [ ] Triggers on version tags (v*.*.*)
- [ ] Validation job runs tests and lints
- [ ] Uses goreleaser-action@v6
- [ ] Verification job confirms module fetchable
- [ ] Permissions: contents: write

### codeql.yml
- [ ] Triggers include scheduled runs (weekly)
- [ ] Language: go
- [ ] Permissions: security-events: write
- [ ] SARIF upload configured

## Phase 7: Testing Infrastructure Assessment

### Directory Structure
- [ ] `testing/` directory exists
- [ ] `testing/README.md` exists
- [ ] `testing/helpers.go` exists
- [ ] `testing/helpers_test.go` exists
- [ ] `testing/integration/` exists
- [ ] `testing/integration/README.md` exists
- [ ] `testing/benchmarks/` exists
- [ ] `testing/benchmarks/README.md` exists

### Helper Quality
- [ ] Helpers call `t.Helper()`
- [ ] Helpers accept `*testing.T` as first parameter
- [ ] Helpers are domain-specific (not generic)
- [ ] Build tag `//go:build testing` used

### Package Structure
- [ ] 1:1 test mapping (source.go ↔ source_test.go)
- [ ] No orphan test files
- [ ] Tests use `-race` flag

## Phase 8: Cross-Cutting Concerns

### Consistency
- [ ] Package name consistent across all files
- [ ] Go version consistent (go.mod, CI matrix, README)
- [ ] golangci-lint version consistent (Makefile, CI)
- [ ] Repository URLs correct in all templates

### Security
- [ ] gosec enabled in linting
- [ ] CodeQL workflow present
- [ ] SARIF uploads configured
- [ ] SECURITY.md exists

### Developer Experience
- [ ] `make help` provides clear guidance
- [ ] `make check` is the go-to validation command
- [ ] Pre-commit hooks available via `make install-hooks`
- [ ] Local CI simulation via `make ci`
