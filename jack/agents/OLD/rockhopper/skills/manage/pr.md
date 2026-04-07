# PR

Creating, commenting on, and triaging pull request feedback.

## Creation

After Midgel has committed all changes and the work is ready, Zidgel creates the pull request. The PR title and description follow the ROCKHOPPER protocol — professional, factual, no agent names or crew roles.

```bash
# Create the PR
gh pr create --title "[concise title]" --body "[description following ROCKHOPPER protocol]"
```

The PR description should include:
- Summary of what was implemented and why
- Affected areas
- Test coverage summary (from Kevin's test summary)
- Any notable design decisions

## Commenting

All PR comments go through the ROCKHOPPER protocol. Run `/protocol` before posting.

### Language Rules

All comments MUST:
- Be neutral and professional in tone
- Read as documentation, not conversation
- Focus on facts: what, why, status
- Use third-person or passive voice

All comments MUST NOT:
- Reference agent names or crew roles
- Read as inter-agent dialogue
- Include character voice or personality
- Use first person ("I analyzed...", "We decided...")

### Comment Types

**Reviewer Response — Dismiss:**

When a reviewer comment is being dismissed with rationale:

```markdown
[Explain why the current approach is correct or intentional]

[Reference relevant design decisions, standards, or constraints if applicable]
```

**Reviewer Response — Acknowledge:**

When a reviewer comment is being accepted and will be addressed:

```markdown
Valid point. This will be addressed in a follow-up commit.

[Brief description of what will change]
```

**Status Update:**

When reporting on workflow or CI status:

```markdown
## Status

[What happened and current state]

### Next Steps
- [What will be done]
```

### Posting

```bash
# Reply to a specific review comment
gh api repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies -f body="[response]"

# Resolve a review thread (requires the thread's node ID)
gh api graphql -f query='mutation { resolveReviewThread(input: { threadId: "[thread_node_id]" }) { thread { isResolved } } }'

# Find thread node IDs
gh api graphql -f query='query { repository(owner: "{owner}", name: "{repo}") { pullRequest(number: {pr}) { reviewThreads(first: 50) { nodes { id isResolved comments(first: 1) { nodes { body } } } } } } }'
```

## Triage

When reviewer comments arrive, the Captain and Fidgel triage together:

| Weight | Path |
|--------|------|
| Style preference or misunderstanding | Dismiss with rationale |
| Trivial fix (typo, naming, formatting) | Fix directly, acknowledge |
| Moderate fix (logic change, missing case) | Micro Build + Review cycle |
| Significant change (scope or architecture) | Micro Plan → Build → Review cycle |

### Triage Process

1. Read each reviewer comment
2. Fidgel assesses the technical weight — is this a genuine defect, style preference, or misunderstanding?
3. Captain assesses whether it changes what we're delivering
4. Decide the path together
5. Post responses via ROCKHOPPER protocol

### Self-Check

Before posting, verify:
- [ ] No agent names appear anywhere
- [ ] No crew roles appear anywhere
- [ ] No first-person voice
- [ ] Tone is neutral and professional
- [ ] Response addresses the specific point raised
