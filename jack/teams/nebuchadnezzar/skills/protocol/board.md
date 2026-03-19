# Task Board

The task board is the coordination mechanism during Build. Morpheus constructs two boards — one for the core subteam, one for the mechanical subteam. Agents self-serve from their board. Task status is the handoff.

## Claiming

- Check the board for unblocked, unclaimed tasks
- Claim by setting status to `in_progress`
- One agent per task — if it is already `in_progress`, move to the next
- When complete, set status to `completed`
- Do not claim tasks whose dependencies are not yet `completed`

## Who Does What

### Core Board

| Agent | Board Interaction |
|-------|-------------------|
| Neo | Claims pipeline and infrastructure tasks, marks complete |
| Trinity | Claims integration test tasks, marks complete |

### Mechanical Board

| Agent | Board Interaction |
|-------|-------------------|
| Switch | Claims unblocked build tasks, marks complete |
| Apoc | Claims unblocked build tasks, marks complete |
| Mouse | Claims unblocked unit test tasks, marks complete |
| Cypher | Does not claim from the board — validates builder and tester output before task completion |

### Above Both

| Agent | Board Interaction |
|-------|-------------------|
| Morpheus | Constructs both boards, monitors health, intervenes on stuck tasks, available for support |

## The Rule

Task status is the handoff. If you want to know whether something is done, read the board. If you want to know who is working on what, read the board. Do not message for information the board already contains.
