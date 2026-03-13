# Comment Test Plan Checklist

## Phase 1: Verify Inputs

- [ ] `assess-plan` has been completed
- [ ] Per-chunk testing map is available
- [ ] Flow awareness is documented
- [ ] Infrastructure needs are listed
- [ ] Open questions are listed

## Phase 2: Draft Comment

### Overview Section
- [ ] Testing approach summarised (test types being used)
- [ ] Overall risk assessment stated
- [ ] Infrastructure needs mentioned at a high level

### Per-Chunk Coverage Table
- [ ] Every chunk from the execution plan has a row
- [ ] Chunk names match the execution plan exactly
- [ ] Test type is specific (unit, integration, benchmark, helper)
- [ ] Primary risk is concrete, not generic
- [ ] Key verifications are specific and actionable

### Infrastructure Section
- [ ] Helpers to create are listed
- [ ] Scaffolding needs are listed
- [ ] Integration scenarios are listed
- [ ] Benchmark needs are listed
- [ ] Each item is concrete enough to act on

### Flow Section
- [ ] When test work begins is stated
- [ ] Idle periods are identified
- [ ] Quick wins vs heavy lifts are noted
- [ ] Advance work opportunities are noted

### Open Questions Section
- [ ] All unresolved items from assess-plan are listed
- [ ] Each question is specific and attributable
- [ ] Questions that were resolved during assessment are excluded

## Phase 3: Quality Check

- [ ] Chunk names match the execution plan
- [ ] No vague language ("test edge cases", "verify correctness")
- [ ] Risks are honest — not overclaiming coverage
- [ ] Every row in the table maps to actionable test work
- [ ] Comment reads as standalone documentation
- [ ] No agent names, crew roles, or internal workflow references

## Phase 4: Post

- [ ] Post via `gh issue comment [number] --body "[content]"`
- [ ] Verify the comment was posted successfully

## Phase 5: Approval

### Request
- [ ] Identify the execution plan author
- [ ] Send approval request via SendMessage
- [ ] Message references the posted comment
- [ ] Message is concise — the comment speaks for itself

### Iterate (if changes requested)
- [ ] Feedback understood — clarifying questions asked via SendMessage if needed
- [ ] Testing strategy updated to address feedback
- [ ] Issue comment edited with revised plan
- [ ] Changes confirmed with plan author via SendMessage
- [ ] Repeat until approved

### Confirm
- [ ] Plan author has approved the test plan
- [ ] Test plan is locked — both parties have agreed
