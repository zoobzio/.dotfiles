# Bedrock Create

Set up the foundational infrastructure for a Go package: module configuration, tooling, CI/CD, and repository files.

**Excludes:** README (use `pkg-readme-create`), documentation (use `pkg-docs-create`)

## Scope

| Category | Files |
|----------|-------|
| Go Module | `go.mod` |
| Repository Files | `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md`, `.gitignore` |
| Tooling Config | `.golangci.yml`, `.codecov.yml`, `.goreleaser.yml` |
| Build System | `Makefile` |
| CI Workflows | `.github/workflows/ci.yml`, `coverage.yml`, `release.yml`, `codeql.yml` |
| Testing Infrastructure | `testing/` directory structure |

## Execution

1. Read `checklist.md` in this skill directory
2. Ask user: "What is the package name?" and "What does this package do?"
3. Determine scope: new package or adding bedrock to existing?
4. Create files per specifications in checklist
5. Verify with `make check`

## Specifications

### Go Module

```go
module github.com/zoobzio/[package]

go 1.24

toolchain go1.25.x
```

### Linting (.golangci.yml)

MUST use version 2 format with these linters enabled:

Security: `gosec`, `errorlint`, `noctx`, `bodyclose`, `sqlclosecheck`
Quality: `govet`, `ineffassign`, `staticcheck`, `unused`, `errcheck`, `errchkjson`, `wastedassign`
Best practices: `gocritic`, `revive`, `unconvert`, `dupl`, `goconst`, `godot`, `misspell`, `prealloc`, `copyloopvar`

See checklist for exact configuration.

### Coverage (.codecov.yml)

| Metric | Target | Threshold |
|--------|--------|-----------|
| Project | 70% | 1% |
| Patch | 80% | 0% |

### Makefile Targets

REQUIRED targets: `test`, `test-unit`, `test-integration`, `test-bench`, `lint`, `lint-fix`, `coverage`, `clean`, `check`, `ci`, `install-tools`, `install-hooks`, `help`

See checklist for exact implementation.

### CI Workflows

- **ci.yml**: Test matrix (Go 1.24, 1.25), lint, security scan, benchmarks
- **coverage.yml**: Coverage with Codecov upload, PR comments
- **release.yml**: Validate → GoReleaser → Verify → Notify
- **codeql.yml**: Security analysis with scheduled runs

See checklist for exact workflow content.

### Testing Infrastructure

```
testing/
├── README.md
├── helpers.go        # Domain-specific test helpers
├── helpers_test.go   # Helpers themselves tested
├── integration/
│   └── README.md
└── benchmarks/
    └── README.md
```

## Prohibitions

DO NOT:
- Use Go version below 1.24
- Skip any required Makefile targets
- Omit security linters from golangci-lint config
- Use golangci-lint v1 format (must use v2)

## Output

A complete infrastructure setup that:
- Enables local development with `make check`
- Runs comprehensive CI on push/PR
- Automates releases with GoReleaser
- Maintains consistent code quality via linting
- Tracks coverage with Codecov
