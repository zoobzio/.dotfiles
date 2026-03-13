# Commission Checklist

## Phase 1: Verify Plan Artifacts

- [ ] Fidgel's architecture spec is posted on the issue
- [ ] Midgel's execution plan is posted on the issue
- [ ] Kevin's test strategy is posted on the issue
- [ ] All three are consistent — no contradictions between artifacts
- [ ] All Plan-phase questions are resolved (no open SendMessage threads)

## Phase 2: Create Tasks

### Build Tasks
For each chunk in the execution plan:
- [ ] Build task created with subject `build: <chunk>`
- [ ] Description includes scope, produces, depends on
- [ ] Dependencies set against other build tasks where identified

### Pipeline Tasks (if any)
For each pipeline stage:
- [ ] Pipeline task created with subject `pipeline: <stage>`
- [ ] Dependencies set against mechanical prerequisites

### Test Tasks
For each build/pipeline task:
- [ ] Corresponding test task created with subject `test: <what>`
- [ ] Description includes test types, key cases, risks (from Kevin's strategy)
- [ ] Test task blocked by its corresponding build task (`addBlockedBy`)

### Scope Lock
- [ ] "scope locked" task created
- [ ] All build and test tasks blocked by "scope locked"

## Phase 3: Verify Board

- [ ] Every build chunk has a task
- [ ] Every build task has a corresponding test task
- [ ] Dependencies are correct (no circular dependencies)
- [ ] No orphan tasks (tasks with no path to completion)
- [ ] Task count matches execution plan

## Phase 4: Post and Release

- [ ] Board summary posted to the issue
- [ ] Support signal included in summary
- [ ] Run `/protocol` for ROCKHOPPER voice before posting
- [ ] "scope locked" marked complete — board released
- [ ] Issue label updated to `phase:build`
- [ ] Crew notified via SendMessage — Build is active
