# Bug Protocol

When Kevin or Fidgel (in test support mode) finds a bug:

1. Create a bug task: subject describes the defect, description includes what was tested, expected vs actual, and which build task produced the faulty code
2. Set the bug task to block downstream tasks that depend on the fix
3. Mark the current test task as blocked by the bug task (via TaskUpdate with addBlockedBy)
4. Message the responsible builder with the bug details (messages are still used for context that doesn't fit in a task description)
5. The builder claims the bug task, fixes the defect, and marks the bug task complete
6. The test task unblocks, and the tester re-tests
