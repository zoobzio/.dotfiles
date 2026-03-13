# Scope Checklist

## Phase 1: Read the Input

- [ ] Issue or user request read thoroughly
- [ ] Original intent understood
- [ ] Motivation ("why") identified
- [ ] Existing content preserved (if augmenting)

## Phase 2: Draft Requirements

For each requirement:
- [ ] Specific — single valid interpretation
- [ ] Testable — verifiable without subjective judgment
- [ ] Scoped — clear boundary
- [ ] Independent — no implementation assumptions
- [ ] Describes "what" not "how"

### Completeness
- [ ] Happy path covered
- [ ] Error cases covered
- [ ] Edge cases considered (empty, nil, zero, max, concurrent)
- [ ] Scope boundaries explicit (in/out)

## Phase 3: Draft Acceptance Criteria

For each criterion:
- [ ] Measurable — pass/fail
- [ ] Observable — verifiable from outside the implementation
- [ ] Complete — covers the requirement it validates
- [ ] Minimal — tests one thing

### Completeness
- [ ] Every requirement has at least one criterion
- [ ] No criterion is ambiguous
- [ ] No criterion requires knowing the implementation to evaluate

## Phase 4: Post to Issue

- [ ] Requirements posted
- [ ] Acceptance criteria posted as checklist
- [ ] Scope boundaries posted (in scope / out of scope)
- [ ] `phase:plan` label applied
- [ ] Run `/protocol` for external voice before posting
