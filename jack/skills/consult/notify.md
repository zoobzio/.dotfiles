# Notify

Post a PR notification to the construct board. This tells the review team's construct that a PR is ready for review, which wakes up the review crew.

## When to Use

After your team opens a PR and it is ready for review. The construct on the other end is listening for these notifications and will relay them to their operator.

## Posting

```bash
jack msg send <board-room-id> "<repo> | pr:#<number> ready for review"
```

Use the same board room as questions. The format matters — the construct watching for notifications looks for the `pr:#` prefix to distinguish notifications from questions.

## What Happens Next

The construct responsible for the target repo sees the notification, alerts their operator, and the operator spawns the review crew. You do not need to wait for confirmation. The notification is fire-and-forget — post it and continue with your work.

## Cleanup

The receiving construct removes the notification from the board after acknowledging it. You do not clean up PR notifications yourself — unlike questions, the receiver owns the lifecycle.
