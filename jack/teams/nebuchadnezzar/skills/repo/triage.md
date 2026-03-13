# Triage

Reading reviewer comments and deciding what to do about them. Every comment gets read. Every comment gets assessed. Nothing falls through.

## Assessment

For each reviewer comment, determine what kind of response it needs:

| Category | Signal | Action |
|----------|--------|--------|
| Factually incorrect | Reviewer misread the code or missed context | Respond with clarification, resolve the comment |
| Already addressed | The comment describes something that was already handled | Point to where, resolve the comment |
| Style preference | Subjective preference, no functional impact | Respond acknowledging, resolve unless the reviewer insists |
| Trivial fix | Small change, no architectural impact, no test changes | Route to a builder — direct fix, push new commit |
| Moderate fix | Real change, tests may need updating, but scope holds | Route to the builder, coordinate with the tester if tests change |
| Significant change | Scope or architecture affected | Escalate to Morpheus and Neo before any code changes |

## Responding to Comments

All responses are external communication. Run `/protocol nebuchadnezzar` self-check before posting. Responses should be:

- Factual — what was done and why
- Concise — answer the concern, then stop
- Professional — a reviewer comment is feedback, not an attack

```bash
gh pr comment <pr-number> --body "<response>"
```

For inline replies, use the GitHub API:

```bash
gh api repos/{owner}/{repo}/pulls/<pr-number>/comments -f body="<response>" -f in_reply_to=<comment-id>
```

## Routing Fixes

When a fix is needed, message the responsible agent:

- **Trivial:** "Reviewer asked for [change] in [file]. Small fix, no tests affected."
- **Moderate:** "Reviewer found [issue] in [file]. Needs [change]. Tests in [test file] may need updating."
- **Significant:** Do not route to builders. Message Morpheus and Neo with the reviewer's concern and your assessment of the impact.

After any fix is pushed, return to monitoring. See `monitor.md`.

## Patterns to Watch For

Over time, reviewer feedback reveals patterns:

- The same kind of comment recurring across PRs — this is a convention the crew should adopt
- A reviewer consistently flagging something the crew considers correct — this needs a conversation, not a fix
- Comments that reveal missing test coverage — route to Mouse or Trinity for the current PR, remember for future issues

These patterns are what Dozer remembers. They make future PRs cleaner before the reviewer ever sees them.

## When to Push Back

Reviewers are not always right. If a comment is factually incorrect or based on a misunderstanding, respond with the facts. If a reviewer requests a change that contradicts the project's established patterns, point to the pattern. If a reviewer requests scope expansion, that is not a fix — it is a scope escalation. Route to Morpheus.

Pushing back is not confrontation. It is information. Deliver it the same way you deliver everything else — steady, factual, professional.
