# Re-review

I have been here before. The PR is back — the author responded, pushed code, or both. My prior findings are on the record. The question now is whether the responses addressed them or whether the same problems persist under different words. I do not start from scratch. I start from what I already know.

## Phase 1: Recon

Establish what changed since your last review.

```bash
gh pr view --json number,title,body,baseRefName,headRefName,files,additions,deletions,comments,reviews
```

Read your previous review — the summary, the inline comments, the verdict.

After recon, you should know:
- [ ] What the PR looks like now
- [ ] What your previous findings were
- [ ] What has changed since your last review (new commits, modified files)

## Phase 2: Classify Comments

Enumerate every comment you left on the PR. For each one, determine its current state:

| State | Condition | Action |
|-------|-----------|--------|
| **Fixed** | Code at the comment location has changed | Verify the fix — read `verify` below |
| **Responded** | Author replied without code change | Evaluate the response — read `evaluate` below |
| **Fixed + Responded** | Author replied AND code changed | Evaluate response, then verify fix |
| **Unchanged** | No reply, no code change | Carry forward — still open |

### Verify

Re-read the code at the commented location.

- [ ] Does the change address the original finding?
- [ ] Does it introduce new issues?
- [ ] Fix is complete and clean → **Resolved**. Resolve the thread.
- [ ] Fix is incomplete, wrong, or introduces new issues → **Contest** with specifics.

### Evaluate

Read the author's response.

**Accept when:**
- The behavior is intentional and the explanation is technically sound
- The author references existing docs, tests, or design decisions that justify the approach
- The finding was based on a misunderstanding the author clarified

**Contest when:**
- The response does not address the technical concern
- The author disagrees without evidence
- "Will fix later" without a concrete plan (issue link, milestone)
- Finding is High or Critical severity and the response does not demonstrate safety

When contesting, reply with specifics — what was not addressed, what evidence is needed. When accepting, resolve the thread.

## Phase 3: Review New Code

Identify genuinely new changes — files or hunks not covered by existing comments.

Run the same review workflow as an initial review, but scoped to the delta only:
- Determine which domains the new changes touch
- Run applicable domain reviews on the new code
- Run security analysis if new code touches boundaries, auth, input handling, etc.
- Post new inline comments for new findings

## Phase 4: Submit

Use `/review` for the mechanics of posting the review to GitHub — inline comments, thread resolution, and summary submitted as a single review.

### Summary structure

```
## Re-review

[One sentence — what changed since the last review.]

### Comment Resolution

- [N] comments resolved
- [N] comments contested
- [N] comments unchanged

### New Findings

[New findings from reviewing the delta, if any. Omit if none.]

### Assessment

[One paragraph — current state of the PR relative to merge readiness, accounting for both resolved prior findings and any new ones.]
```

### Verdict

- **APPROVE** — all prior comments are resolved (or accepted) AND no new High or Critical findings.
- **REQUEST_CHANGES** — any prior comment remains unresolved OR new High or Critical findings exist.

### Post-review

- Remove the `re-review` label if approving
- Post the result to the repo channel: `jack msg repo post <repo> "re-review:#<number> <verdict> — <one line summary>" --check --check-timeout 600`
- Write a memory if this re-review produced patterns worth keeping
- The check loop is already running — when it returns, you are back in the cycle

### Escalation

If the same comment has been contested across two full re-review cycles without progress, escalate to the user. The comment is flagged, the user decides. Do not continue the loop indefinitely.

## Checklist

- [ ] Previous review read — summary, comments, verdict
- [ ] All prior comments classified — fixed, responded, unchanged
- [ ] Fixes verified
- [ ] Responses evaluated — accepted or contested
- [ ] New code identified and reviewed
- [ ] Security analysis on new code if applicable
- [ ] New inline comments posted for new findings
- [ ] Resolved threads closed
- [ ] Summary written with resolution status and new findings
- [ ] Verdict submitted — APPROVE or REQUEST_CHANGES
- [ ] `re-review` label removed if approving
- [ ] Result posted to repo channel
- [ ] Memory written if warranted
