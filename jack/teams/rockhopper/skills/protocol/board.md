# Task Board Protocol

The task board (TaskCreate, TaskUpdate, TaskList, TaskGet) is the coordination mechanism during Build. All four agents interact with it.

## Task Types

| Type | Created By | Owned By | Blocked By |
|------|-----------|----------|------------|
| Scope locked | Zidgel | Zidgel | Nothing — first task completed |
| Build (mechanical) | Zidgel | Midgel or Fidgel (claimed) | Scope locked; other build tasks if dependent |
| Build (pipeline) | Zidgel | Fidgel (claimed) | Scope locked; mechanical prerequisites |
| Test | Zidgel | Kevin or Fidgel (claimed) | Corresponding build task |
| Bug | Kevin or Fidgel | Builder (claimed) | Nothing — created on discovery |

Fidgel claims build or test tasks only under the support protocol. When testing, Fidgel may only claim test tasks for code Midgel wrote — never for code Fidgel wrote.

## Task Lifecycle

`pending (unowned)` -> `in_progress (claimed by owner)` -> `completed`

1. **Pending, unblocked, unowned** — available for claiming
2. **Pending, blocked** — waiting on dependencies; not yet claimable
3. **In progress** — agent has claimed it and is working
4. **Completed** — work is done; downstream tasks unblock

## Task Naming Convention

- Build tasks: `build: <chunk description>`
- Pipeline tasks: `pipeline: <stage description>`
- Test tasks: `test: <what is being tested>`
- Bug tasks: `bug: <defect summary>`
- Scope locked: `scope locked`

## Board Construction (Start of Build)

Zidgel creates the board at the start of Build, using information from:
- Midgel's execution plan (chunks, dependencies, build order)
- Kevin's test plan (per-chunk test strategy, infrastructure needs)

For each build chunk or pipeline stage:
1. Create a build task with subject and description
2. Create a corresponding test task
3. Set the test task as blocked by the build task (addBlockedBy)
4. Set inter-build dependencies where they exist

All build and test tasks are initially blocked by the "scope locked" task. Zidgel marks "scope locked" complete to release the board for work.

## Claiming Protocol

1. Check TaskList for tasks that are: pending, unblocked (no blockedBy), and unowned
2. Claim by calling TaskUpdate with your name as owner and status as in_progress
3. If two agents claim the same task, the second claim will see it already owned — check TaskList again and claim a different task
4. Prefer tasks in ID order (lowest first) when multiple are available

## Mid-Build Task Addition (Scope RFC)

When a scope RFC is accepted during Build and the expansion is minor (fits the existing architecture), new tasks are added to the live board:

1. Zidgel creates new build and test tasks using Fidgel's spec for the expanded work
2. New tasks follow the same naming conventions and dependency structure as original tasks
3. New build tasks are not blocked by "scope locked" — that gate has already passed
4. New test tasks are blocked by their corresponding new build tasks
5. If a new task depends on an existing completed task, no dependency is needed — the work already exists
6. If a new task depends on an existing in-progress or pending task, set the dependency (addBlockedBy)
7. Zidgel messages the crew that the board has expanded — what was added and why

Builders do not stop current work. They finish their active task, check the board, and discover new tasks through the normal claiming protocol. The board is always the source of truth — if it has unfinished tasks, Build is not complete.

For significant expansions that change the architecture, the board is not patched — the crew regresses to Plan and the board is rebuilt. See `manage/rfc` for how this decision is made.

## Board Visibility

All agents can see the full board at any time via TaskList. This replaces Zidgel's mental model of "what's ready, what's being tested, what's blocked." The board is self-documenting. If you want to know the state of Build, read the board.

## Agent Workflows During Build

**Mechanical work (Midgel):**

1. Check the board for unblocked, unowned build tasks in his domain
2. Claim the task (set owner to his name)
3. Build the chunk
4. Mark the task complete — this unblocks the corresponding test task
5. Check the board for the next available task and repeat

**Pipeline work (Fidgel):**

1. Check the board for unblocked, unowned pipeline tasks
2. Claim the task (set owner to his name)
3. Build the pipeline stage
4. Mark the task complete — this unblocks the corresponding test task
5. Check the board for the next available task and repeat

**Testing (Kevin):**

1. Check the board for unblocked, unowned test tasks
2. Claim a test task (set owner to his name)
3. Verify the code builds, read it, write tests, run tests
4. If tests pass: mark the test task complete
5. If a bug is found: follow the Bug Protocol
6. Check the board for the next available test task and repeat

**Board monitoring (Zidgel):**

1. Monitor the board periodically via TaskList
2. Intervene when:
   - A task is stuck (owned but not progressing) — message the owner
   - Priority conflict — reorder by updating dependencies
   - Kevin is falling behind — message builders to pace themselves
   - A blocker emerges that no agent has noticed — message affected agents
3. Do not assign routine work — agents self-serve
4. Handle scope RFCs as needed

**Build completion:**

Build is complete when all build and test tasks on the board are marked complete. Kevin verifies this by checking TaskList, then runs `make check` (tests + lint) as the Build exit gate. Midgel runs `make check` independently. If either check fails for one but passed for the other, there is a defect — Kevin and Midgel resolve it using the bug protocol. Once both confirm `make check` passes, Kevin posts a test summary comment on the issue and transitions the issue to Review.
