# Follow Checklist

## Phase 1: Read the Execution Plan

- [ ] Execution plan comment located on the issue
- [ ] Full plan read before assessing individual chunks
- [ ] Overall shape noted (chunk count, dependency depth, parallel lanes)

## Phase 2: Understand Each Chunk

For each chunk:

### Mechanical Understanding
- [ ] Can describe what this chunk builds in own words
- [ ] Types, functions, interfaces produced are clear
- [ ] Relationship to preceding and following chunks understood

### Testability
- [ ] Specific behaviours to verify are identifiable
- [ ] Inputs and outputs clear enough to design test cases
- [ ] Test surface is specific (not vague or missing)
- [ ] Error paths identified or implied

### Boundaries
- [ ] Chunk start and end are clear
- [ ] In-scope vs deferred work understood
- [ ] Implicit dependencies identified

## Phase 3: Question the Plan

- [ ] Vague test surfaces questioned via SendMessage to Midgel
- [ ] Missing error paths questioned
- [ ] Long serial chains questioned
- [ ] Chunks with no test surface questioned
- [ ] Unclear boundaries questioned
- [ ] Responses received and incorporated
- [ ] OR: no questions needed — plan is clear

## Phase 4: Design Per-Chunk Strategy

For each chunk:

### Test Type
- [ ] Unit tests needed?
- [ ] Integration tests needed?
- [ ] Benchmarks needed?
- [ ] Helpers needed?
- [ ] All applicable test types identified

### Risk and Cases
- [ ] Primary risk category identified (specific to this chunk)
- [ ] Key test cases outlined (specific, not vague)
- [ ] Happy path, error path, and boundary cases identified
- [ ] Bug likelihood locations identified

## Phase 5: Assess Flow and Infrastructure

### Flow
- [ ] Chunks that immediately unblock test work identified
- [ ] Idle periods mapped
- [ ] Quick wins vs heavy lifts ordered

### Infrastructure
- [ ] New test helpers needed? Listed
- [ ] Test scaffolding present?
- [ ] Integration scenarios requiring setup? Listed
- [ ] Benchmarks warranted? For which chunks?

## Phase 6: Post Test Plan

- [ ] Overview section written
- [ ] Per-chunk coverage table complete (chunk names match execution plan)
- [ ] Infrastructure needs listed
- [ ] Flow mapping included
- [ ] Open questions listed
- [ ] No vague language
- [ ] Posted via `gh issue comment`

## Phase 7: Approval

- [ ] Approval requested from Midgel via SendMessage
- [ ] If changes requested: plan updated, comment edited, confirmed
- [ ] Midgel has approved the test plan
- [ ] Test plan is locked
