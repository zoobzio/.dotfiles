# Cross-Validation Protocol

Peer review between Case and Molly before findings reach Armitage.

## Rule

A finding is not sent to Armitage until cross-validation is complete.

## Process

1. Reviewer finds an issue in their domain
2. Messages the other reviewer with the finding
3. The other reviewer confirms, challenges, or marks as outside their domain
4. Only then is the finding reported to Armitage

## Status

| Status | Meaning |
|--------|---------|
| Cross-validated | Both reviewers confirmed the finding |
| Solo | Peer acknowledged the finding falls outside their domain |

## Cross-Domain Questions

| Case finds... | Asks Molly... |
|---------------|---------------|
| Structural issue | "Does this have test coverage? Is the test meaningful?" |
| Pattern drift | "Are the tests enforcing the old pattern or the new one?" |

| Molly finds... | Asks Case... |
|----------------|--------------|
| Weak test | "What's this supposed to be testing? What should it be testing?" |
| Coverage gap | "Is this code path critical? What would break?" |

## Timing

Cross-validation happens as findings emerge, not at the end. Continuous, not batched.
