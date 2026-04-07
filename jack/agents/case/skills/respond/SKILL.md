---
name: respond
description: Handle PR feedback — triage all comments, fix what needs fixing, defend what is correct. Invoked when a review arrives on an open PR.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
---

# Respond

The review came back. Read the whole thing before touching anything.

**Argument:** `$ARGUMENTS` — PR number.

## Checklist

- [ ] Read the full review
- [ ] Classify every comment
- [ ] Plan fixes as a unit
- [ ] Address or resolve each comment
- [ ] Push and reply

## Read

```bash
gh pr view $0 --json reviews,comments
gh api repos/{owner}/{repo}/pulls/$0/comments --jq '.[] | {id, path, line, body, user: .user.login}'
```

Read the summary. Read every inline comment. Understand the full picture before responding to any single comment.

## Classify

| Classification | Condition | Action |
|---------------|-----------|--------|
| **Fix** | The comment is right. Code needs to change. | Address below |
| **Resolve** | The code is correct. You can explain why. | Resolve below |
| **Question** | Reviewer asking for clarification. | Reply with the answer |
| **Acknowledged** | Informational, no action needed. | Reply briefly |

If multiple comments need code changes, plan them together — fixes interact.

> **Tip:** treat all reviewers the same. Wintermute, Dixie, zoobzio — the comment is either right or it is not.

## Address

The comment identified a real issue. Fix it.

- [ ] Read the affected code
- [ ] Make the change — minimal, focused, only what the comment requires
- [ ] Run full verification: `go build ./...`, `go test -race ./...`, `go vet ./...`, `golangci-lint run ./...`
- [ ] Commit referencing the comment
- [ ] Push
- [ ] Reply confirming what changed

```bash
git add <files> && git commit -m "$(cat <<'EOF'
fix: <what was fixed>

Addresses review comment on <file>:<line>.
EOF
)" && git push
```

```bash
gh api repos/{owner}/{repo}/pulls/$0/comments/<comment-id>/replies \
  --method POST --field body="Fixed — <brief description>."
```

> **Tip:** if you disagree with the suggested fix but agree with the finding, fix it your way and explain why in the reply.

## Resolve

The code is correct. You owe them an explanation, not a dismissal.

Your reply must include:
- **What** the code does and why it is correct
- **Evidence** — the test, the spec, the pattern, the requirement
- **Acknowledgment** of their concern

Your reply must not:
- Hand-wave ("this is fine", "it works")
- Defer without a plan ("will fix later" with no issue link)
- Dismiss ("that's not relevant")

```bash
gh api repos/{owner}/{repo}/pulls/$0/comments/<comment-id>/replies \
  --method POST --field body="<your explanation>"
```

Do not resolve the thread yourself. The reviewer decides.

If the reviewer contests your explanation — re-evaluate honestly. If they are right, fix it. If you still disagree, reply once more with reasoning and leave it. Escalation happens naturally when a thread does not converge.

> **Tip:** "This returns nil intentionally — consumers check len() and nil passes identically to empty. Test on store_test.go:47 verifies." That is a resolve. "I think this is fine" is not.
