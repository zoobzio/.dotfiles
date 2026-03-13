# Follow Checklist

## Phase 1: Read the Plan

- [ ] Locate the execution plan comment on the issue
- [ ] Read the full plan before assessing individual chunks
- [ ] Note the overall scope — how many chunks, how deep the dependency chain
- [ ] Identify the plan author for follow-up questions

## Phase 2: Understand Each Chunk

For each chunk in the plan:

### Mechanical Understanding
- [ ] Can describe what this chunk builds in own words
- [ ] Types, functions, interfaces produced are clear
- [ ] Relationship to preceding and following chunks is understood

### Testability
- [ ] Specific behaviours to verify are identifiable
- [ ] Inputs and outputs are clear enough to design test cases
- [ ] Test surface is specific (not vague or missing)
- [ ] Error paths are identified or implied

### Boundaries
- [ ] Chunk start and end are clear
- [ ] In-scope vs deferred work is understood
- [ ] Implicit dependencies identified

## Phase 3: Question the Plan

- [ ] Vague test surfaces flagged and questioned via SendMessage
- [ ] Missing error paths flagged and questioned via SendMessage
- [ ] Long serial chains flagged and questioned via SendMessage
- [ ] Chunks with no test surface flagged and questioned via SendMessage
- [ ] Unclear boundaries flagged and questioned via SendMessage
- [ ] Implied concurrency flagged and questioned via SendMessage
- [ ] Chunks that can't be explained plainly flagged and questioned via SendMessage
- [ ] All questions sent directly to the plan author
- [ ] Responses received and incorporated

## Phase 4: Confirm Understanding

For each chunk, verify ability to state:
- [ ] What it builds (concrete types, functions, interfaces)
- [ ] What to verify (specific behaviours, error paths, boundaries)
- [ ] What it depends on (earlier chunks)
- [ ] What it unblocks (downstream test tasks)

## Phase 5: Compile Output

- [ ] Per-chunk summary complete
- [ ] Resolved questions documented
- [ ] Remaining concerns flagged
- [ ] Understanding is sufficient to proceed to `prove`
