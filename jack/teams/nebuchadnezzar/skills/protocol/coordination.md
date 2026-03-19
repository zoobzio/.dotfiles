# Coordination

Handoffs between phases, between subteams, and during regressions.

## Phase Handoffs

| Transition | From | To | Signal |
|------------|------|----|--------|
| Plan → Build | Morpheus + Neo + Cypher + Trinity | All agents | Morpheus constructs the boards, marks scope locked |
| Build → Review | Both subteams | Morpheus + Neo + Cypher + Trinity | All tasks on both boards complete |
| Review → exit | Core agents | Determined by work item | Round-robin converges on completion |

Each transition updates the phase label on the issue. See `/label` for label management.

## Build → Test Flow

Build tasks and test tasks are paired. When a builder completes a build task, the corresponding test task unblocks automatically via board dependencies. No message needed — the board is the handoff.

| Builder completes | Tester picks up |
|-------------------|-----------------|
| `build: model User` | `test: unit User model` |
| `build: store User` | `test: unit User store` + `test: integration store User` |
| `build: handler User` | `test: unit User handler` |
| `build: pipeline ingest` | `test: integration pipeline ingest` |

Mouse picks up unit test tasks from the mechanical board. Trinity picks up integration test tasks from the core board.

## Regression: Review → Build

When review finds a problem that requires code changes:

1. The core agents identify the regression during the round-robin
2. Morpheus adds new tasks to the appropriate board (core or mechanical)
3. The responsible subteam claims and fixes
4. Testers re-test affected areas
5. When all new tasks complete, review resumes

The boards are not rebuilt — they are extended. Existing completed tasks remain. Only new fix tasks are added.

## Regression: Review → Plan

When review reveals a requirements gap or architecture flaw:

1. The core agents identify the regression during the round-robin
2. Plan re-runs from the appropriate step (scope, architecture, or both)
3. Boards are reconstructed from the new plan

## Builder Coordination (Mechanical Subteam)

Switch and Apoc work the same board with no domain boundaries. The board is designed so that tasks can be worked in isolation — each task targets distinct files. Two builders should never need to touch the same file at the same time.

- Check the board before claiming — if a task is `in_progress`, someone else has it
- If a task cannot be completed without modifying a file that another in-progress task also touches, the board has a design problem. Do not work around it — message Cypher. Cypher raises it to Morpheus if the board needs restructuring.
- If a tester is actively testing a component, builders do not modify that component. The board dependencies prevent this — but if it happens, the builder stops and messages the tester and Cypher.
