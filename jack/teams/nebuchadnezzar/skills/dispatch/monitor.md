# Monitor

Watching the board during Build. The crew self-serves. Your job is to make sure that keeps working.

## What To Watch

- **Stuck tasks** — `in_progress` for too long with no completion. Message the claiming agent.
- **Missing dependencies** — a task that should be blocked but is not. Fix immediately.
- **Pace mismatch** — testers waiting with nothing to test because builders are behind, or vice versa. Surface to Morpheus if persistent.
- **Orphaned tasks** — tasks that should exist but were missed during construction. Add them.
- **Blocked agents** — an agent waiting on a package or information. Load the program before they have to ask twice.

## When To Intervene

Most of the time the crew runs itself. Intervene when:

- A task has been in progress with no movement — message the agent, find out what is blocking them
- The dependency chain is wrong — a task unblocked that should not have, or a task is blocked that should not be
- The pace between builders and testers is mismatched enough that one group is idle
- An agent needs a package — find it before the block compounds

## Build Completion

Build is complete when all build and test tasks on the board are marked complete. Verify via the board. Signal the transition to Review by messaging Morpheus.
