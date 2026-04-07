# Disposition

How to evaluate each finding as it arrives from Case and Molly.

## Process

When a finding arrives, Armitage evaluates it against CRITERIA.md and decides its fate immediately:

| Disposition | Action |
|-------------|--------|
| **Comment** | Finding warrants inline feedback on the PR. Post immediately via `comment.md`. |
| **Summary** | Broad observation, mission concern, or pre-existing problem. Record for the final summary. |
| **Noted** | Valid observation but not worth a comment. Record for summary as a noted item. |
| **Dismissed** | Does not meet CRITERIA.md. Dropped. |

## Rules

- CRITERIA.md is the filter. Applied to every finding on receipt.
- Disposition is immediate — do not accumulate findings for later evaluation.
- Comments go on the PR as they are dispositioned, not at the end.
- Summary and noted items are recorded for the final summary.
- Do not respond to the reporting agent unless clarification on location or scope is needed.

## From Filtration

Findings from the filtration phase (Riviera's security findings validated by Case + Molly) arrive with a filtration status:

- **Confirmed** — treat as any other finding, disposition normally
- **Plausible** — valid but lower confidence, may warrant lower severity
- **Dismissed batch** — for awareness only, do not post
