# Comment Plan Checklist

## Phase 1: Verify Inputs

- [ ] `decompose` has been completed
- [ ] Chunk list is available with all five fields per chunk
- [ ] Dependency graph is documented
- [ ] Build order is determined with rationale
- [ ] Flow assessment is documented
- [ ] Support signal is assessed

## Phase 2: Draft Comment

### Overview Section
- [ ] Number of chunks stated
- [ ] Dependency shape summarised
- [ ] Expected flow summarised

### Chunk Details
For each chunk:
- [ ] Name is short and descriptive
- [ ] Scope lists specific files (created or modified)
- [ ] Produces lists specific types, functions, interfaces
- [ ] Depends on references chunk names (or states none)
- [ ] Test surface is specific and actionable

### Dependency Graph
- [ ] All chunks are represented
- [ ] All dependencies are shown
- [ ] No circular dependencies
- [ ] Graph matches the per-chunk "depends on" fields

### Build Order
- [ ] Sequence is stated
- [ ] Rationale for ordering is explained
- [ ] Constrained orderings are acknowledged

### Flow Section
- [ ] When test work begins is stated
- [ ] Idle periods are identified
- [ ] Quick wins vs heavy lifts are noted

### Support Signal
- [ ] Assessment stated (support warranted or not)
- [ ] Reasoning provided

## Phase 3: Quality Check

- [ ] Every architectural element appears in at least one chunk
- [ ] No vague language ("adds stuff", "does configuration")
- [ ] Flow is honest — idle periods not hidden
- [ ] All five fields present for every chunk
- [ ] Comment reads as standalone documentation
- [ ] No agent names, crew roles, or internal workflow references

## Phase 4: Post

- [ ] Post via `gh issue comment [number] --body "[content]"`
- [ ] Verify the comment was posted successfully

## Phase 5: Approval

### Request
- [ ] Identify the architect
- [ ] Send approval request via SendMessage
- [ ] Message references the posted comment
- [ ] Message is concise — the comment speaks for itself

### Iterate (if changes requested)
- [ ] Feedback understood — clarifying questions asked via SendMessage if needed
- [ ] Execution plan updated to address feedback
- [ ] Issue comment edited with revised plan
- [ ] Changes confirmed with architect via SendMessage
- [ ] Repeat until approved

### Confirm
- [ ] Architect has approved the execution plan
- [ ] Execution plan is locked — both parties have agreed
- [ ] Tester can now assess the plan
