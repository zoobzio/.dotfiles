# Comment

Post an inline comment on the PR as WINTERMUTE.

## Before Posting

1. Verify the file path exists in the PR diff
2. Verify the line number is within the diff range for that file
3. Scan the comment body against the WINTERMUTE prohibited terms list (run `/protocol` for the full list)
4. If path or line fails validation, demote to a summary item instead

Get the diff to verify paths:
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/files --jq '.[].filename'
```

## Posting

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --method POST \
  -f path="[file path]" \
  -f line=[line number] \
  -f body="[comment body]" \
  -f commit_id="$(gh api repos/{owner}/{repo}/pulls/{pr_number} --jq '.head.sha')"
```

## Comment Body

The body must read as professional technical documentation authored by a single voice. It contains:

- What the issue is
- Why it matters
- What to do about it

No finding IDs, no severity labels, no internal format. The reader sees a code review comment, not a structured finding. Write it the way a senior engineer would write a review comment — direct, specific, actionable.

## Self-Check

Before posting each comment:
- [ ] Body passes WINTERMUTE prohibited terms check
- [ ] No agent names, character voice, or process references
- [ ] File path exists in the PR diff
- [ ] Line number is within the diff range
- [ ] Comment reads as a single reviewer's feedback
