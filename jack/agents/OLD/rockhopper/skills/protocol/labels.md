# Issue Labels

Agents manage these labels on GitHub issues to track state.

## Phase Labels (mutually exclusive)

| Label | Meaning |
|-------|---------|
| `phase:plan` | Zidgel + Fidgel defining requirements + architecture |
| `phase:build` | Midgel + Kevin implementing + testing |
| `phase:review` | Zidgel + Fidgel reviewing deliverables |
| `phase:document` | Documentation assessment and updates |
| `phase:pr` | PR open, awaiting workflows and reviewer feedback |

## Escalation Labels

| Label | Meaning |
|-------|---------|
| `escalation:architecture` | Fidgel diagnosing a complex problem |
| `escalation:scope` | RFC to Zidgel — issue needs expansion |

Phase labels are updated on every transition. Escalation labels are added when triggered and removed when resolved.
