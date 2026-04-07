# Support Protocol

When the board is heavily mechanical — many build tasks for Midgel, many test tasks for Kevin, but few or no pipeline tasks for Fidgel — either Midgel or Kevin may request Fidgel's support during Build. Fidgel shifts from consultant to active builder or tester alongside the crew.

This is identified during Plan when the board is constructed. If Zidgel and Fidgel see that the work is predominantly mechanical, Fidgel flags his availability for support. The request can also come during Build if Midgel or Kevin sees the workload is heavier than expected.

**One absolute rule: Fidgel does not test his own code.**

Support mode follows the same board protocol — Fidgel claims unblocked, unowned tasks. What changes is which tasks he may claim:

## Midgel Requests Build Support

1. Fidgel claims unblocked, unowned build tasks (mechanical work, not pipeline)
2. Fidgel builds the chunk following Midgel's patterns and the spec
3. Fidgel marks the task complete — the corresponding test task unblocks
4. Kevin tests the code. Fidgel does not claim test tasks for code he wrote
5. Fidgel and Midgel coordinate to avoid conflicting file changes — they message each other when claiming tasks in overlapping areas

## Kevin Requests Test Support

1. Fidgel claims unblocked, unowned test tasks — but only for code Midgel wrote
2. Fidgel writes tests following Kevin's patterns and conventions
3. If Fidgel finds a bug, he follows the bug protocol (creates bug task, messages Midgel)
4. Fidgel does not claim test tasks for code he wrote during the same Build

## Combined Support

Fidgel may provide both build and test support in the same Build. The constraint remains: any code Fidgel wrote is tested by Kevin, never by Fidgel. The board makes this traceable — the owner field on a build task identifies who wrote the code, so Kevin and Fidgel can verify who should test what.

Support does not change Fidgel's other responsibilities. He remains available for diagnostic escalation and architectural consultation throughout Build.
