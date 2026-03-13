# Bedrock Audit

Evaluate existing package infrastructure against standards and provide actionable recommendations.

**Excludes:** README (use `pkg-readme-audit`), documentation (use `pkg-docs-audit`)

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
2. Work through each phase systematically
3. Compile findings into structured report

## Specifications

### Go Module Requirements

- Module path MUST follow `github.com/zoobzio/[package]`
- Go version MUST be 1.24 or higher
- Toolchain directive MUST be present: `toolchain go1.25.x`
- `go mod tidy` MUST produce no changes

### Repository Files

#### LICENSE
- MUST be MIT License format
- MUST have correct year and copyright holder

#### CONTRIBUTING.md
- MUST reference `make help`
- MUST explain fork/clone/branch workflow
- MUST list prerequisites

#### SECURITY.md
- MUST have vulnerability reporting instructions
- MUST specify contact method

#### .gitignore
MUST include:
- Binaries: `*.exe`, `*.dll`, `*.so`, `*.dylib`
- Test files: `*.test`, `*.out`, `coverage.*`
- IDE files: `.idea/`, `.vscode/`, `*.swp`
- OS files: `.DS_Store`, `Thumbs.db`
- Build artifacts: `dist/`, `vendor/`

### Tooling Requirements

See checklist for exact configuration specifications.

### Makefile Requirements

MUST have these targets:
- `help`, `test`, `test-unit`, `test-integration`, `test-bench`
- `lint`, `lint-fix`, `coverage`, `clean`
- `check`, `ci`, `install-tools`, `install-hooks`

### CI Workflow Requirements

See checklist for exact workflow specifications.

## Output

### Report Structure

```markdown
## Summary
[One paragraph: overall infrastructure health and primary recommendation]

## Coverage Matrix

| Category | Status | Primary Issue |
|----------|--------|---------------|
| Go Module | [✓/~/✗] | |
| Repository Files | [✓/~/✗] | |
| Tooling Config | [✓/~/✗] | |
| Makefile | [✓/~/✗] | |
| CI Workflows | [✓/~/✗] | |
| Testing Infrastructure | [✓/~/✗] | |

## Strengths
[What the infrastructure does well]

## Issues
[Prioritized list with impact and recommendations]

## Missing Components
[Files that should exist but don't]

## Quick Wins
[Low-effort fixes with high impact]
```

Status legend: ✓ Compliant, ~ Partial, ✗ Missing/Non-compliant

## Removal Targets

The following should be flagged for removal if present:

- `.github/PULL_REQUEST_TEMPLATE.md` — CI enforces quality; template is ceremony
- `.github/ISSUE_TEMPLATE/` — Adds friction without value; good reporters don't need them, bad reporters ignore them
