# Labels

When and how to apply labels on GitHub issues. Run `/protocol` for the label definitions — this sub-file covers the decision-making.

## Phase Labels

Phase labels are mutually exclusive. Update on every phase transition.

| Transition | New Label | Who Updates |
|------------|-----------|-------------|
| Scope posted | `phase:plan` | Zidgel (via `/scope`) |
| Board released | `phase:build` | Zidgel (via `/commission`) |
| Build complete | `phase:review` | Kevin |
| Review passes | `phase:pr` | Zidgel |

### On Regression

When a phase regresses (e.g., Review → Build):
1. Update the label to the earlier phase
2. Post a comment explaining the regression
3. Notify affected agents via SendMessage

## Escalation Labels

Escalation labels are additive — they coexist with phase labels.

| Label | Applied When | Removed When |
|-------|-------------|--------------|
| `escalation:scope` | Agent raises a scope RFC | Captain resolves the RFC |
| `escalation:architecture` | Agent escalates to Fidgel | Fidgel resolves the diagnosis |

## Command

```bash
# Apply a label
gh issue edit <number> --add-label "<label>"

# Remove a label
gh issue edit <number> --remove-label "<label>"
```
