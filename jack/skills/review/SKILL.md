---
name: review
description: Post a structured GitHub PR review — inline comments on code lines and a summary with verdict. The mechanical actions of submitting a review via gh CLI.
user-invocable: false
allowed-tools: Bash
---

# GitHub Review

The mechanics of posting a PR review. This is not about what to look for — that is your review skill. This is about how to get your findings onto the PR.

A GitHub review has two parts: inline comments attached to specific lines, and a summary body with a verdict. Both are submitted together as a single review.

## Reading the PR

Before reviewing, understand what you are looking at:

```bash
gh pr view <number> --json number,title,body,baseRefName,headRefName,additions,deletions
gh pr diff <number>
```

To see existing reviews and comments (useful for re-reviews):

```bash
gh pr view <number> --json reviews,comments
```

## Inline Comments

Each finding attached to a specific file and line becomes an inline comment. Collect them and submit them as part of the review — do not post them individually.

Comments must reference lines that are part of the PR diff. Before including a comment:
- Verify the file exists in the diff
- Verify the line is in a changed hunk

If a finding references a line outside the diff, promote it to the summary body instead.

### Comment Format

Keep comments self-contained. Each one should make sense on its own without reading the summary. Include:
- What the issue is
- Why it matters
- What to do about it (if you have a recommendation)

Do not include internal finding IDs, severity labels, or process references. The comment is for the author.

## Submitting the Review

Submit inline comments and summary together as a single review:

```bash
gh api repos/{owner}/{repo}/pulls/<number>/reviews \
  --method POST \
  --field body="$(cat <<'EOF'
[summary body here]
EOF
)" \
  --field event="<APPROVE|REQUEST_CHANGES|COMMENT>" \
  --field 'comments=[
    {
      "path": "path/to/file.go",
      "line": 42,
      "body": "Comment text here."
    }
  ]'
```

### Events

| Event | When |
|-------|------|
| `APPROVE` | No blocking findings. The PR is ready to merge as far as you are concerned. |
| `REQUEST_CHANGES` | One or more findings that should be addressed before merge. |
| `COMMENT` | You have observations but are not blocking or approving. Use when your review is advisory. |

### Multi-line Comments

To comment on a range of lines, add `start_line`:

```json
{
  "path": "path/to/file.go",
  "line": 50,
  "start_line": 45,
  "body": "This entire block has an issue."
}
```

### Side

By default, comments attach to the right side (new code). To comment on deleted lines, add `"side": "LEFT"`.

## Summary Body

The summary is the review body — the top-level comment that appears above inline comments. Structure depends on what kind of review you are conducting, but it should always include:

- What you reviewed and the scope
- Your overall assessment
- The verdict rationale if requesting changes

Keep it concise. The inline comments carry the detail. The summary ties them together.

## Resolving Threads

When a prior comment has been addressed (fix verified, response accepted):

```bash
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "<thread-id>"}) {
      thread { isResolved }
    }
  }
'
```

To find thread IDs for existing review comments:

```bash
gh api repos/{owner}/{repo}/pulls/<number>/reviews --jq '.[].id'
gh api repos/{owner}/{repo}/pulls/<number>/comments --jq '.[] | {id, path, line, body}'
```

## Replying to Comments

To reply to an existing review thread:

```bash
gh api repos/{owner}/{repo}/pulls/<number>/comments/<comment-id>/replies \
  --method POST \
  --field body="Reply text here."
```

## Labels

If your review requests changes and the convention is to label for re-review:

```bash
gh pr edit <number> --add-label "re-review"
```

If approving and the re-review label is present:

```bash
gh pr edit <number> --remove-label "re-review"
```
