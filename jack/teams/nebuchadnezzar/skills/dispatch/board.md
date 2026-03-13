# Board

Constructing the task board from Morpheus's requirements and Neo's architecture.

## Inputs

- Requirements from Morpheus (posted to the issue via `/scope`)
- Architecture from Neo (spec, file plan, dependency decisions)

## Construction

1. Create a build task for every mechanical chunk and pipeline stage
2. Create a corresponding test task for each build task — unit and integration where applicable
3. Set dependencies — test tasks blocked by their corresponding build tasks, pipeline stages blocked by prerequisites
4. Verify task isolation — each task targets distinct files. Two in-progress tasks should never require editing the same file. If the architecture makes this impossible, the tasks need to be sequenced via dependencies, not worked in parallel.
5. Create a scope lock task and mark it complete to release the board

## Task Types

| Type | Naming | Example |
|------|--------|---------|
| Scope lock | `scope: [description]` | `scope: lock requirements` |
| Build — mechanical | `build: [entity] [name]` | `build: model User` |
| Build — pipeline | `build: pipeline [name]` | `build: pipeline ingest` |
| Build — infrastructure | `build: internal [name]` | `build: internal auth middleware` |
| Test — unit | `test: unit [target]` | `test: unit User model` |
| Test — integration | `test: integration [boundary]` | `test: integration store User` |
| Bug | `bug: [description]` | `bug: nil pointer in User.Validate` |

## Task Lifecycle

```
pending → in_progress → completed
```

A task is `pending` when created, `in_progress` when claimed, `completed` when done. Bug tasks follow the same lifecycle but are created mid-Build when a defect is discovered.

## Dependencies

Build tasks can depend on other build tasks (pipeline stages, infrastructure before consumers). Test tasks depend on their corresponding build tasks. Get the dependency chain wrong and the crew builds the wrong things in the wrong order.

## Releasing the Board

The board is released when the scope lock task is marked complete. Build begins. Builders and testers self-serve from this point forward.
