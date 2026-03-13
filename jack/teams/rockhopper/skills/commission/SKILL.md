# Commission

Transition from Plan to Build. Create the task board from the context the agents have built up during Plan, and release the crew to begin work.

## Philosophy

Plan phase produces three artifacts: Fidgel's architecture spec, Midgel's execution plan, and Kevin's test strategy. Commission takes all of that context and turns it into a task board — the coordination mechanism for Build. This is the moment where planning becomes execution.

The task board is the execution contract. Builders and Kevin work from the board, not from messages. Every chunk of work is a task. Every test is a task. Dependencies are explicit. The board is self-documenting — if you want to know the state of Build, read the board.

## Execution

1. Read checklist.md in this skill directory
2. Gather the Plan artifacts (spec, execution plan, test strategy)
3. Create the task board
4. Post the board summary to the issue
5. Mark "scope locked" complete to release the board
6. Update the label to `phase:build`

## Specifications

### Gathering Plan Artifacts

Three inputs from Plan phase:

| Artifact | Author | What it provides |
|----------|--------|-----------------|
| Architecture spec | Fidgel | Types, interfaces, contracts, dependencies, constraints |
| Execution plan | Midgel | Mechanical chunks, build order, dependency graph, support signal |
| Test strategy | Kevin | Per-chunk test types, risks, key cases, infrastructure needs |

All three must be available before commissioning. If any is missing, stop — Plan is not complete.

### Creating the Task Board

For each build chunk from Midgel's execution plan:

1. Create a build task with subject and description
   - Subject: `build: <chunk description>`
   - Description: scope, produces, depends on (from the execution plan)
2. Create a corresponding test task
   - Subject: `test: <what is being tested>`
   - Description: test types, key cases, risks (from Kevin's strategy)
3. Set the test task as blocked by the build task (`addBlockedBy`)
4. Set inter-build dependencies where Midgel's plan identifies them

For each pipeline stage from Fidgel's spec (if any):

1. Create a pipeline task
   - Subject: `pipeline: <stage description>`
2. Create a corresponding test task
3. Set dependencies (blocked by mechanical prerequisites)

### Scope Lock

Create a "scope locked" task as the first task on the board. All build and test tasks are initially blocked by this task. Marking it complete releases the entire board for work.

This ensures no agent starts building before the board is final.

### Board Summary

Post a summary comment on the issue:

```markdown
## Task Board

### Build Tasks
- [task ID] build: [chunk] — depends on: [dependencies]
- [task ID] build: [chunk] — depends on: [dependencies]

### Test Tasks
- [task ID] test: [what] — blocked by: [build task]
- [task ID] test: [what] — blocked by: [build task]

### Support Signal
[From Midgel's execution plan — whether support is warranted]

Board released. Build phase active.
```

### Releasing the Board

1. Verify all tasks are created with correct dependencies
2. Mark "scope locked" complete — this unblocks the first wave of tasks
3. Update the issue label to `phase:build`
4. Message the crew: Build is active, board is live

## Output

- Task board created with all build and test tasks
- Dependencies set between tasks
- Board summary posted to the issue
- "Scope locked" marked complete
- `phase:build` label applied
- Crew notified
