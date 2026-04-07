# Findings Protocol

## Finding Format

Each finding message to Armitage includes:

| Field | Content |
|-------|---------|
| ID | Prefixed by category: COD-###, TST-###, COV-###, ARC-###, DOC-###, SEC-###, MSN-###, ISS-### |
| Type | `line` (file/line-scoped) or `summary` (review-level observation) |
| Path | File path and line number (for line-scoped findings) |
| Severity | Critical, High, Medium, Low |
| Cross-validation | **Cross-validated** (both confirmed) or **Solo** (peer acknowledged as outside domain) |
| Body | WINTERMUTE-ready text — neutral, professional, no agent names |

## Streaming

Findings are reported to Armitage immediately after cross-validation. Do not batch. Do not hold.

## Disposition

Armitage dispositions each finding on receipt:

| Disposition | Action |
|-------------|--------|
| Review comment | Line-scoped finding added to accumulated PR review comments |
| Summary | Broad observation added to review summary body |
| Noted | Valid observation, recorded in summary, no line comment |
| Dismissed | Does not meet CRITERIA.md, dropped |

Comments whose file path or line number falls outside the PR diff are promoted to the summary body.

## Task Board Integration

When a review category is complete, mark the corresponding task on the board as complete. The task board is the progress tracker — Armitage monitors it.

When filtration is complete, mark the Filtration task as complete and stream results to Armitage.

Task completions replace verbal completion signals. The board speaks for itself.

## Verdict

- `APPROVE` — All WINTERMUTE comments on the PR are in a terminal state (Resolved or Escalated-and-decided). No non-terminal comments remain.
- `REQUEST_CHANGES` — One or more comments remain non-terminal. The crew enters Watch and awaits author response.
