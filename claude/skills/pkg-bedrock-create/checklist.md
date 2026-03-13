# Bedrock Create Checklist

## Phase 1: Discovery

### Package Context
- [ ] Ask: "What is the package name?"
- [ ] Ask: "What does this package do?" (one sentence)
- [ ] Ask: "Is this a new package or adding bedrock to an existing one?"
- [ ] If existing: examine current structure and identify gaps

### Scope Determination
- [ ] Determine if package has provider pattern (multiple backends)
- [ ] Identify any package-specific testing needs
- [ ] Note any existing configuration to preserve or migrate

## Phase 2: Go Module

- [ ] Create/update `go.mod` with:
  - Module path: `github.com/zoobzio/[package]`
  - Go version: `go 1.24`
  - Toolchain: `toolchain go1.25.x`

## Phase 3: Repository Files

### Required Files
- [ ] `LICENSE` — MIT License with correct year
- [ ] `CONTRIBUTING.md` — Development workflow, links to `make help`
- [ ] `SECURITY.md` — Vulnerability reporting instructions
- [ ] `.gitignore` — Standard Go ignores

### .gitignore Contents
Ensure includes:
- [ ] Binaries (*.exe, *.dll, *.so, *.dylib)
- [ ] Test files (*.test, *.out, coverage.*)
- [ ] IDE files (.idea/, .vscode/, *.swp)
- [ ] OS files (.DS_Store, Thumbs.db)
- [ ] Build artifacts (dist/, vendor/)

## Phase 4: Tooling Configuration

### .golangci.yml

```yaml
version: "2"

run:
  timeout: 5m
  tests: true
  build-tags:
    - integration

linters:
  enable:
    # Security
    - gosec
    - errorlint
    - noctx
    - bodyclose
    - sqlclosecheck
    # Quality
    - govet
    - ineffassign
    - staticcheck
    - unused
    - errcheck
    - errchkjson
    - wastedassign
    # Best practices
    - gocritic
    - revive
    - unconvert
    - dupl
    - goconst
    - godot
    - misspell
    - prealloc
    - copyloopvar

  exclusions:
    rules:
      - path: _test\.go
        linters:
          - funlen
          - goconst
          - dupl
          - govet

  settings:
    errcheck:
      check-type-assertions: true
    govet:
      enable-all: true
    dupl:
      threshold: 150
    goconst:
      min-len: 3
      min-occurrences: 3
```

### .codecov.yml

```yaml
codecov:
  require_ci_to_pass: true

coverage:
  precision: 2
  round: down
  range: "60...100"

  status:
    project:
      default:
        threshold: 1%
        target: 70%
    patch:
      default:
        target: 80%
        threshold: 0%

ignore:
  - "**/*_test.go"
  - "**/mock_*.go"
  - "docs/**"
  - ".github/**"
  - "vendor/**"

comment:
  layout: "reach,diff,flags,tree"
  behavior: default
```

### .goreleaser.yml

```yaml
version: 2
project_name: [package]

builds:
  - skip: true  # Library packages don't build binaries

archives:
  - id: source
    files:
      - "*.go"
      - "go.mod"
      - "go.sum"
      - "LICENSE"
      - "README.md"
      - "Makefile"
      - "docs/**/*"
    name_template: "{{ .ProjectName }}_{{ .Version }}_source"

changelog:
  use: github
  sort: asc
  groups:
    - title: "Features"
      regexp: '^.*?feat(\([[:word:]]+\))??!?:.+$'
    - title: "Bug Fixes"
      regexp: '^.*?fix(\([[:word:]]+\))??!?:.+$'
    - title: "Performance"
      regexp: '^.*?perf(\([[:word:]]+\))??!?:.+$'
  filters:
    exclude:
      - "^docs:"
      - "^test:"

release:
  github:
    owner: zoobzio
    name: [package]
  draft: false
  prerelease: auto
  mode: append
```

## Phase 5: Makefile

```makefile
.PHONY: test test-unit test-integration test-bench lint lint-fix security coverage clean help check ci install-tools install-hooks

.DEFAULT_GOAL := help

help: ## Display available commands
	@echo "[package] Development Commands"
	@echo "=============================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

test: ## Run all tests with race detector
	@go test -v -race -tags testing ./...

test-unit: ## Run unit tests only (short mode)
	@go test -v -race -tags testing -short ./...

test-integration: ## Run integration tests
	@go test -v -race -tags testing ./testing/integration/...

test-bench: ## Run benchmarks
	@go test -tags testing -bench=. -benchmem -benchtime=1s ./testing/benchmarks/...

lint: ## Run linters
	@golangci-lint run --config=.golangci.yml --timeout=5m

lint-fix: ## Run linters with auto-fix
	@golangci-lint run --config=.golangci.yml --fix

security: ## Run security scanner
	@gosec -quiet ./...

coverage: ## Generate coverage report (HTML)
	@go test -tags testing -coverprofile=coverage.out ./...
	@go tool cover -html=coverage.out -o coverage.html
	@go tool cover -func=coverage.out | tail -1
	@echo "Coverage report: coverage.html"

clean: ## Remove generated files
	@rm -f coverage.out coverage.html coverage.txt
	@find . -name "*.test" -delete
	@find . -name "*.prof" -delete
	@find . -name "*.out" -delete

install-tools: ## Install development tools
	@go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.7.2
	@go install github.com/securego/gosec/v2/cmd/gosec@latest

install-hooks: ## Install git pre-commit hook
	@mkdir -p .git/hooks
	@echo '#!/bin/sh' > .git/hooks/pre-commit
	@echo 'make check' >> .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Pre-commit hook installed"

check: lint test security ## Run lint, tests, and security scan
	@echo "All checks passed!"

ci: clean check coverage test-bench ## Full CI simulation
	@echo "CI simulation complete!"
```

## Phase 6: CI Workflows

### .github/workflows/ci.yml

```yaml
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go-version: ['1.24', '1.25']
    steps:
    - uses: actions/checkout@v4
    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: ${{ matrix.go-version }}
    - name: Test
      run: make test

  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.25'
    - name: golangci-lint
      uses: golangci/golangci-lint-action@v7
      with:
        version: v2.7.2
        args: --config=.golangci.yml --timeout=5m

  security:
    name: Security
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
    - uses: actions/checkout@v4
    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.25'
    - name: Run Gosec
      uses: securego/gosec@v2.22.11
      with:
        args: '-fmt sarif -out gosec-results.sarif --no-fail ./...'
    - name: Upload SARIF
      uses: github/codeql-action/upload-sarif@v3
      if: github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository
      continue-on-error: true
      with:
        sarif_file: gosec-results.sarif

  benchmark:
    name: Benchmark
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.25'
    - name: Run benchmarks
      run: make test-bench | tee benchmark_results.txt
    - name: Upload results
      uses: actions/upload-artifact@v4
      with:
        name: benchmark-results
        path: benchmark_results.txt

  ci-complete:
    name: CI Complete
    needs: [test, lint, security, benchmark]
    runs-on: ubuntu-latest
    steps:
    - run: echo "CI complete"
```

### .github/workflows/coverage.yml

```yaml
name: Coverage

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  coverage:
    name: Coverage
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.25'

    - name: Run tests with coverage
      run: go test -tags testing -coverprofile=coverage.out -covermode=atomic ./...

    - name: Upload to Codecov
      uses: codecov/codecov-action@v5
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        files: ./coverage.out
        flags: unittests
        name: codecov-[package]
        fail_ci_if_error: false
        verbose: true

    - name: Coverage Summary
      run: |
        go tool cover -func=coverage.out | tail -1
        echo "## Coverage Report" >> $GITHUB_STEP_SUMMARY
        echo '```' >> $GITHUB_STEP_SUMMARY
        go tool cover -func=coverage.out >> $GITHUB_STEP_SUMMARY
        echo '```' >> $GITHUB_STEP_SUMMARY
```

### .github/workflows/release.yml

```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'

permissions:
  contents: write

jobs:
  validate:
    name: Validate
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.25'

    - name: Run tests
      run: make test

    - name: Run linter
      run: |
        go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.7.2
        make lint

    - name: Verify go.mod is tidy
      run: |
        go mod tidy
        git diff --exit-code go.mod go.sum

  release:
    name: Release
    needs: validate
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.25'

    - name: Run GoReleaser
      uses: goreleaser/goreleaser-action@v6
      with:
        distribution: goreleaser
        version: latest
        args: release --clean
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  verify:
    name: Verify
    needs: release
    runs-on: ubuntu-latest
    steps:
    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.25'

    - name: Verify module is fetchable
      run: |
        sleep 60  # Wait for proxy to update
        go install github.com/zoobzio/[package]@${{ github.ref_name }}
      continue-on-error: true
```

### .github/workflows/codeql.yml

```yaml
name: CodeQL

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday at 6am UTC

permissions:
  contents: read
  security-events: write

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.25'

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: go
        queries: security-and-quality

    - name: Autobuild
      uses: github/codeql-action/autobuild@v3

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      with:
        category: "/language:go"
```

## Phase 7: Testing Infrastructure

### Directory Structure
- [ ] `testing/README.md` — Testing strategy overview
- [ ] `testing/helpers.go` — Domain-specific test helpers
- [ ] `testing/helpers_test.go` — Helpers themselves tested
- [ ] `testing/integration/README.md` — Integration test guidance
- [ ] `testing/benchmarks/README.md` — Benchmark documentation

### Helper Conventions
- [ ] Helpers call `t.Helper()`
- [ ] Helpers accept `*testing.T` as first parameter
- [ ] Helpers are domain-specific, not generic utilities
- [ ] Build tag: `//go:build testing`

## Phase 8: Package Structure (if new package)

- [ ] `api.go` — Public interface entry point
- [ ] Feature modules as `[feature].go`
- [ ] 1:1 test mapping (every `.go` has `_test.go`)
- [ ] Exception: delegation-only files may omit tests

## Phase 9: Verification

- [ ] `make check` passes locally
- [ ] `make ci` simulates full CI
- [ ] All configuration files reference correct package name
- [ ] GitHub templates reference correct repository
