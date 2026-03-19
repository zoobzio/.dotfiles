# Comment Lifecycle Protocol

Operational procedures for tracking and resolving PR comments across review passes.

## Internal States (Pre-PR)

| State | Owner | Transition |
|-------|-------|------------|
| Discovered | Case, Molly, or Riviera | Finding identified during review |
| Validated | Case + Molly | Cross-validated per cross-validation protocol |
| Filtered | Riviera → Case + Molly | Security findings only — passed through filtration |
| Dispositioned | Armitage | Posted as PR comment. Enters external lifecycle. |

Internal states are governed by existing protocols (cross-validation, filtration, findings). This protocol governs the external lifecycle.

## External States (On PR)

| State | Meaning | Next States |
|-------|---------|-------------|
| Open | Comment posted, awaiting author | Responded, Fixed, Responded + Fixed |
| Responded | Author replied, no code change | Accepted, Contested |
| Fixed | Author pushed code addressing the finding | Verified, Contested |
| Responded + Fixed | Author replied AND pushed code | Evaluate response + verify fix |
| Contested | Crew disagrees, replies with more context | Open |
| Accepted | Crew accepts author's response | Resolved |
| Verified | Fix confirmed by Case + Molly | Resolved |
| Resolved | Terminal. Armitage resolves the thread. | — |
| Escalated | Impasse. User intervenes. Terminal. | — |

## Rescoping (Armitage)

On a re-review work item, Armitage enumerates all WINTERMUTE comments on the PR and determines each comment's current state.

For each comment:
1. Has the author replied? Check for replies in the thread.
2. Has the relevant code changed? Compare current diff against the comment's file and line.
3. Both? Neither?

Build the re-review task board with three task types:

| Task Type | Trigger | Action |
|-----------|---------|--------|
| Verify | Code changed at comment location | Case + Molly re-review the code. Is the fix real? Does it introduce new issues? |
| Evaluate | Author responded without code change | Case + Molly assess the response. Accept or contest. |
| New Code | New files or hunks not covered by existing comments | Full review of genuinely new changes. |

Comments with no author activity stay Open. No task needed this pass.

## Evaluate Criteria (Case + Molly)

**Accept when:**
- The author explains the behavior is intentional and the explanation is technically sound
- The author references existing documentation, tests, or design decisions that justify the approach
- The finding was based on a misunderstanding that the author clarified

**Contest when:**
- The response does not address the technical concern
- The author disagrees without evidence or reasoning
- The response is "will fix later" without a concrete plan (issue link, milestone)
- The finding is severity High or Critical and the response does not demonstrate why it is safe

When contesting, Case or Molly drafts the reply. Armitage posts it via WINTERMUTE. The comment returns to Open.

## Verify Criteria (Case + Molly)

1. Re-read the code at the commented location
2. Determine if the fix addresses the original finding
3. Check for regressions introduced by the fix
4. Fix is good and introduces no new issues: Verified
5. Fix is incomplete, wrong, or introduces new issues: Contest with specifics

## Resolution (Armitage)

When a comment reaches Accepted or Verified, Armitage resolves the PR conversation thread.
- Verified: no additional reply needed. The fix speaks for itself.
- Accepted: Armitage posts a brief acknowledgment via WINTERMUTE before resolving.

## Escalation

Armitage escalates a comment when:
- Two full re-review cycles have passed without progress on the same comment
- Case and Molly cannot reach agreement on whether to accept or contest
- The author explicitly refuses to address a High or Critical finding

Escalated comments are flagged to the user. The user decides. The comment is terminal regardless of the decision.

## Approval Gate

Armitage may submit Approve ONLY when every WINTERMUTE comment on the PR is in a terminal state (Resolved or Escalated-and-decided). If any comment is non-terminal, the verdict is Request Changes.
