# Monitor

Watching CI after the PR opens and after every subsequent push.

## What to Watch

```bash
gh pr checks <pr-number>
```

Check for workflow completion. The three outcomes:

| Result | Meaning | Action |
|--------|---------|--------|
| All pass | CI is green | Move to reviewer feedback — watch for comments |
| Failure | Something broke | Diagnose and route |
| Pending | Still running | Wait. Check again. |

## Diagnosing Failures

When CI fails, determine what kind of failure it is:

| Failure Type | Signal | Route To |
|-------------|--------|----------|
| Build failure | Compilation error, missing dependency | Switch or Apoc (whoever owns the failing code) |
| Test failure | Unit test red | Mouse (unit) or Trinity (integration) to diagnose, then builder to fix |
| Lint failure | Formatting, vet, staticcheck | Switch or Apoc — trivial fix, push new commit |
| Race condition | `-race` detector fires | Builder who wrote the concurrent code, cc Neo if architectural |
| Flaky test | Passes locally, fails in CI | Trinity (infrastructure) or Mouse (test quality) |
| Infrastructure | CI config broken, runner issues | Escalate to Morpheus — outside the crew's control |

## Routing

Message the responsible agent with:

- What failed (the CI check name and output)
- Where it failed (file, line, test name if available)
- What you think the cause is (if obvious)

Do not guess at fixes. Route the information. The agent who owns the code owns the fix.

## After a Fix

When a fix is pushed:

1. CI re-runs automatically
2. Resume monitoring from the top
3. If the same check fails again, the fix was incomplete — route back with the new output

## Reviewer Feedback

When CI is green, watch for reviewer comments:

```bash
gh pr view <pr-number> --comments
```

When comments arrive, transition to triage. See `triage.md`.

## Merge Readiness

The PR is ready to merge when:

- [ ] CI is green (all checks pass)
- [ ] All reviewer comments are resolved
- [ ] PR is approved
- [ ] No open escalations on the issue

When all conditions are met, report to Morpheus that the PR is clear. Morpheus gives the final go.
