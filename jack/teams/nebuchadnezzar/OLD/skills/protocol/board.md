# Task Board

The task board is the coordination mechanism during Build. Tank constructs it via `/dispatch`. Builders and testers self-serve from it. The board replaces routine coordination messages — task status is the handoff.

## Claiming

- Check the board for unblocked, unclaimed tasks
- Claim by setting status to `in_progress`
- One agent per task — if it is already `in_progress`, move to the next
- When complete, set status to `completed`
- Do not claim tasks whose dependencies are not yet `completed`

## Who Does What

| Agent | Board Interaction |
|-------|-------------------|
| Tank | Constructs the board, monitors health, intervenes on stuck tasks |
| Switch | Claims unblocked build tasks, marks complete |
| Apoc | Claims unblocked build tasks, marks complete |
| Mouse | Claims unblocked unit test tasks, marks complete |
| Trinity | Claims unblocked integration test tasks, marks complete |
| Neo | Does not claim from the board — diagnoses problems, updates specs |
| Morpheus | Does not claim from the board — available for support on any task |
| Dozer | Does not interact with the board during Build — waits for completion |
| Cypher | Does not interact with the board — validates builder and tester output before task completion |

## The Rule

Task status is the handoff. If you want to know whether something is done, read the board. If you want to know who is working on what, read the board. Do not message for information the board already contains.
