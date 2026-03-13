# Mechanical Review

Independent verification. Does it build, does it pass, is the documentation accurate?

## Philosophy

Trust but verify. The tester's tests passed. The builder confirmed the build. But a third independent run catches what the other two missed — racy tests, environment-dependent assumptions, flaky assertions, platform-specific behaviour. These are real defects, and catching them in Review is substantially preferable to catching them in CI.

Documentation accuracy is also mechanical. If the docs say one thing and the code does another, that is a defect — regardless of which one is "right."

## Execution

1. Run `make check` independently
2. Run `go test -race ./...` independently
3. Verify documentation accuracy against the implementation
4. Record findings
5. Render judgment

## Specifications

### Build Verification

```bash
make check
```

| Check | Question |
|-------|----------|
| Clean build | Does it build without warnings or errors? |
| Linting | Do all linters pass? |
| Formatting | Is all code formatted? |
| Vet | Does `go vet` pass? |

If `make check` fails, stop. This is a Build regression — no further review until it passes.

### Test Verification

```bash
go test -race ./...
```

| Check | Question |
|-------|----------|
| All pass | Do all tests pass? |
| Race-free | Does the race detector report any issues? |
| No flakes | Do tests pass consistently across multiple runs if suspect? |
| No skips | Are any tests skipped that shouldn't be? |

A test that passes without the race detector but fails with it has a concurrency defect. A test that passes intermittently has a determinism defect. Both are real bugs.

### Documentation Accuracy

| Artifact | Check |
|----------|-------|
| README | Does it accurately describe the current state of the package? |
| docs/ | Do guides and references match the implemented API and behaviour? |
| Godocs | Do function and type docs match their actual behaviour? |
| Examples | Do documented examples compile and produce the described output? |

Documentation is verified against the implementation, not the spec. If the implementation changed during Build, the docs must reflect reality — not the plan.

### Regression Paths

| Finding | Path |
|---------|------|
| Build failure | Back to Build — builder fixes |
| Test failure | Back to Build — determine if test defect or implementation defect |
| Race condition | Back to Build — builder fixes the concurrency issue |
| Documentation inaccuracy | Back to Build — architect updates docs |

All mechanical failures regress to Build. If a mechanical failure reveals an architectural flaw (e.g., a race condition that cannot be fixed without redesigning the concurrency model), escalate to the technical review for a Plan regression assessment.

## Output

A determination:
- **Pass** — builds clean, tests pass with race detector, documentation accurate
- **Regress to Build** — specific failures listed with responsible agent
