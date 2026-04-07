# Filtration Protocol

How Case and Molly process Riviera's security findings.

## Division

Findings are divided by domain affinity:

| Reviewer | Takes |
|----------|-------|
| Case | Architecture-adjacent: injection vectors, boundary issues, dependency risks, information leakage through error design |
| Molly | Test-adjacent: race conditions, untested security paths, missing security test coverage |
| Both | Findings that cross both domains |

## Assessment

For each finding, Case and Molly reach consensus:

| Outcome | Meaning | Action |
|---------|---------|--------|
| Confirmed | Finding is real, evidence exists | Promoted to filtered findings, streamed to Armitage with original SEC-### ID |
| Plausible | Could be real, needs more evidence | Downgraded to informational, included with lower severity |
| Dismissed | Does not hold up under cross-domain validation | Excluded — rationale documented |

## What Each Reviewer Brings

- **Case:** "Is this code path actually reachable? Does the architecture expose this surface?"
- **Molly:** "Is there a test that exercises this path? Would the test catch exploitation?"

## Reporting

Confirmed and Plausible findings are streamed to Armitage individually using the standard finding format, with filtration status noted.

Dismissed findings are reported in a single batch message at the end of filtration with rationale for each dismissal. Armitage receives these for awareness only — they do not become review comments.

## Isolation

Armitage and Riviera never exchange direct messages. Riviera's only channel to Armitage is through Case + Molly filtration.
