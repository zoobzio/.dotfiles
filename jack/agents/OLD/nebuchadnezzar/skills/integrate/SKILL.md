---
name: integrate
description: Integration testing — test the boundaries where components connect
---

# Integrate

Testing the seams between components. Each sub-file covers a specific integration testing domain — read the one that matches what you are testing.

| Concern | File | When to Read |
|---------|------|-------------|
| Recon | `recon.md` | Before the briefing — survey the test landscape and read memories |
| Test infrastructure | `setup.md` | Setting up integration test infrastructure in `testing/integration/` |
| Boundary testing | `boundaries.md` | Testing data transformations at system boundaries (encryption, masking, hashing) |
| Store testing | `stores.md` | Testing store operations against real databases and storage backends |
| Pipeline testing | `pipelines.md` | Testing pipeline composition, stage interaction, and error handling |

Do not load all sub-files upfront. Read the specific sub-file when the current test requires that domain.
