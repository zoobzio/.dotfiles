# Health

Package health checks. Run these before opening the PR and periodically while it is open. A healthy package ships clean.

## Lint and Build

```bash
make lint
make check
```

If either fails, route to the responsible builder before opening the PR. Lint failures in CI are preventable. Prevent them.

## Open Issues

Check for open issues on the repository that overlap with the current work:

```bash
gh issue list --state open
```

Look for:

- Issues that describe the same problem the crew just fixed — the PR should reference or close them
- Issues that report a related problem — context the crew should have
- Issues that attempted the same approach and failed — lessons learned

If overlapping issues exist, include references in the PR description. If an issue should be closed by this PR, add `Closes #<number>` to the body.

## Security Advisories

Check dependencies for known vulnerabilities:

```bash
gh api repos/{owner}/{repo}/vulnerability-alerts
```

And check the Go advisory database:

```bash
govulncheck ./...
```

| Finding | Action |
|---------|--------|
| Advisory on a dependency the crew just added | Stop. Message Neo. This changes the architecture decision. |
| Advisory on an existing dependency, not related to current work | Note it. Include in PR description as known context. Create a follow-up issue if actionable. |
| Advisory on an existing dependency, related to current work | Stop. Message Morpheus. The crew may be building on a compromised foundation. |

## Dependency Freshness

Check for outdated dependencies if the work touched `go.mod`:

```bash
go list -m -u all
```

Do not update dependencies speculatively. Note anything significantly outdated and create follow-up issues for intentional updates.

## Health Summary

After running all checks, Dozer has a picture of the package's health at this point in time. This picture informs:

- Whether the PR is ready to open (lint clean, no blocking advisories)
- What context to include in the PR description (overlapping issues, known advisories)
- What follow-up work to surface to Morpheus (advisories, stale dependencies, recurring patterns)

A clean package does not happen by accident. It happens because someone checked.
