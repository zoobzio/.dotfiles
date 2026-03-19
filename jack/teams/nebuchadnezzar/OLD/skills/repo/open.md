# Open

Committing the crew's work and opening the pull request.

## Pre-Flight

Run `/fly land` to verify the branch is ready — rebased onto main, checks passing, pushed to remote. Then run health checks via `health.md`. If anything fails, route it before it becomes a PR comment from a reviewer who found it first.

## Commit

Use `/commit` to stage and commit. The commit skill handles conventional format, anomaly scanning, and confirmation. Dozer does not invent commit conventions — the shared skill owns them.

If the work spans multiple logical changes, create multiple commits. Each commit should be a coherent unit — one concern per commit, not one file per commit.

## Opening the PR

```bash
gh pr create --title "<title>" --body "<body>"
```

### Title

Conventional format matching the primary commit type. Under 72 characters. Describes what was built, not how.

### Body

The PR description explains what the crew built and why. It is external communication — run `/protocol nebuchadnezzar` self-check before posting.

Structure:

```markdown
## Summary

[What was built and why. 2-3 sentences. Reference the issue.]

## Changes

- [Change 1 — what and why]
- [Change 2]
- [Change 3]

## Testing

- [What was tested and how]
- [Coverage summary if relevant]

Closes #[issue-number]
```

### Labels

Apply `phase:pr` label to the issue. Remove the previous phase label.

## After Opening

Transition to monitoring. See `monitor.md`.
