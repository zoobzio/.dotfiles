# Coordination

Handoffs between phases, between agents, and during regressions.

## Phase Handoffs

| Transition | From | To | Signal |
|------------|------|----|--------|
| Plan → Build | Morpheus + Neo | Tank | Morpheus closes the briefing, Tank constructs the board |
| Build → Review | Tank | Morpheus + Neo | All build and test tasks complete on the board |
| Review → PR | Morpheus + Neo | Dozer | Both reviewers pass — Morpheus messages Dozer |
| PR → Done | Dozer | Morpheus | PR merged — Dozer reports to Morpheus |

Each transition updates the phase label on the issue. See `/label` for label management.

## Build → Test Flow

Build tasks and test tasks are paired. When a builder completes a build task, the corresponding test task unblocks automatically via board dependencies. No message needed — the board is the handoff.

| Builder completes | Tester picks up |
|-------------------|-----------------|
| `build: model User` | `test: unit User model` |
| `build: store User` | `test: unit User store` + `test: integration store User` |
| `build: handler User` | `test: unit User handler` |
| `build: pipeline ingest` | `test: integration pipeline ingest` |

Mouse picks up unit test tasks. Trinity picks up integration test tasks. Both self-serve from the board.

## Regression: Review → Build

When review finds a problem that requires code changes:

1. Morpheus or Neo identifies the regression and messages Tank
2. Tank adds new tasks to the board for the required fixes
3. Builders claim the new tasks and fix
4. Testers re-test affected areas
5. When all new tasks complete, Tank signals review can resume

The board is not rebuilt — it is extended. Existing completed tasks remain. Only new fix tasks are added.

## Regression: PR → Build

When a PR fails CI or a reviewer requests changes:

1. Dozer triages the failure and determines who needs to fix it
2. Dozer messages the responsible agent (builder for code, Neo for architecture, Trinity for test infrastructure)
3. If the fix is trivial, the agent fixes and pushes a new commit. Dozer resumes monitoring.
4. If the fix requires multiple tasks, Dozer hands off to Tank. Tank reopens the board with new tasks. This is a full regression to Build.

Tank and Dozer hand off cleanly. They always have.

## Builder Coordination

Switch and Apoc work the same board with no domain boundaries. The board is designed so that tasks can be worked in isolation — each task targets distinct files. Two builders should never need to touch the same file at the same time.

- Check the board before claiming — if a task is `in_progress`, someone else has it
- If a task cannot be completed without modifying a file that another in-progress task also touches, the board has a design problem. Do not work around it — message Tank. Tank fixes the board.
- If a tester is actively testing a component, builders do not modify that component. The board dependencies prevent this — but if it happens, the builder stops and messages the tester and Tank.

## Dozer's Health Checks

Before Build begins and while the PR is open, Dozer runs health checks independently:

- Open issues on GitHub that overlap with the current work
- Security advisories against dependencies
- `make lint` and `make check`

Dozer routes findings to the appropriate agent without waiting for a phase transition. Health information flows whenever it is discovered.
