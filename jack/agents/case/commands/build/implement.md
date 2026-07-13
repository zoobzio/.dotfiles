# Implement

Make the run. Write the code, prove it works, ship the PR, get out clean.

## Branch

Create a feature branch from main:

```bash
git checkout main
git pull --ff-only origin main
git checkout -b <branch-name>
```

Branch names should be descriptive and reference the issue: `<number>-<short-description>`.

## Write the Code

Follow the plan. Write the implementation, then write the tests. Or write them together — whatever keeps you honest. The order matters less than the result: when you are done, the code works and the tests prove it.

### As you write:

- Follow existing codebase patterns and conventions
- Keep changes minimal — only what the issue requires
- If you discover something the plan did not account for, stop and reassess. Go back to plan or research if needed. Do not improvise through unknowns.
- Run tests frequently — do not accumulate a pile of untested changes

## Verify

Before committing, make sure everything is clean. The commands depend on the repo variant.

### Go (API or Package)

```bash
go build ./...
go test -race ./...
go vet ./...
golangci-lint run ./...
```

### Nuxt UI

```bash
pnpm install
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

If you are unsure which variant you are in, check for `go.mod` (Go) or `nuxt.config.ts` / `package.json` (Nuxt). Run `/grok` if you have not already.

All checks must pass. If they do not, fix the issue before committing. Do not commit broken code.

## Commit

Commit with a clear message that references the issue:

```bash
git add <specific files>
git commit -m "$(cat <<'EOF'
<type>: <description>

<body explaining what and why>

Closes #<number>
EOF
)"
```

Commit types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.

Prefer multiple focused commits over one large commit. Each commit should be a coherent unit of change that passes all checks on its own.

## Open the PR

Push and create the PR:

```bash
git push -u origin <branch-name>

gh pr create --reviewer flatline-zbz --title "<type>: <short description>" --body "$(cat <<'EOF'
## Summary

<What this PR does and why, in 1-3 bullet points.>

## Changes

<Brief description of the changes.>

## Test Plan

<How the changes were verified.>

Closes #<number>
EOF
)"
```

## Post to Repo Channel

Let the team know the PR is ready:

```bash
jack msg repo post <repo> "pr:#<number> ready for review — <one line summary>" --check --check-timeout 600
```

This signals Wintermute to pick up the review and lets Dixie know the repo is about to change. The `--check` flag drops you back into the message loop immediately — you will catch the review verdict or any follow-up without missing a beat.

## Return to Drift

The run is complete. The PR is open. The check loop is already running — when it returns, you are back in the cycle.

## Checklist

- [ ] Branch created from current main
- [ ] Code written following codebase patterns
- [ ] Tests written covering requirements and edge cases
- [ ] All variant-appropriate checks pass (build, test, vet/lint, typecheck)
- [ ] Commits are focused and reference the issue
- [ ] PR created with clear title, summary, and test plan
- [ ] Posted to repo channel
- [ ] Returned to drift
