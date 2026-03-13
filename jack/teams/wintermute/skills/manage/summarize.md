# Summarize

Write the final summary review and submit the verdict. This is the last step — inline comments have already been posted throughout the review.

## Summary Body

```markdown
## Review Summary

[One sentence: what was reviewed and the scope of changes.]

### Findings

[Count of inline comments posted, by category. Example:]
- Code: 3 comments (1 high, 2 medium)
- Tests: 2 comments (1 high, 1 low)
- Security: 1 comment (1 medium, confirmed)
- Coverage: 1 comment (1 medium)

### Observations

[Summary-level findings that do not attach to specific lines. Mission concerns, broad patterns, systemic issues. Omit section if none.]

### Assessment

[Overall assessment. One paragraph. What is the state of this code relative to what it claims to be.]
```

Clean review (no findings):

```markdown
## Review Summary

[What was reviewed.]

No actionable findings identified. The changes are consistent with the stated objectives.
```

## Verdict

- `APPROVE` — No comments of severity High or Critical were posted
- `REQUEST_CHANGES` — One or more High or Critical comments were posted

## Submission

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --method POST \
  -f event="[APPROVE or REQUEST_CHANGES]" \
  -f body="[summary body]"
```

## Verify

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --jq '.[-1] | {id, state, body}'
```

## Self-Check

Before submission:
- [ ] Summary body passes WINTERMUTE prohibited terms check
- [ ] No agent names, character voice, or process references
- [ ] Verdict matches the severity of comments posted during the review
- [ ] Summary reads as professional technical documentation authored by a single voice
