# Analyze Checklist

## Phase 1: Read the Issue

- [ ] Problem statement identified and understood
- [ ] Requirements listed and read
- [ ] Acceptance criteria listed and read
- [ ] Scope boundaries identified (explicit in/out)
- [ ] Context and motivation understood
- [ ] Constraints identified

## Phase 2: Cross-Reference with Briefing

- [ ] Briefing discussion reviewed for relevant context
- [ ] Concerns raised during briefing accounted for
- [ ] Recon findings (source, test, docs) considered for feasibility
- [ ] Veto considerations assessed — is any part technically infeasible?

## Phase 3: Identify Gaps

### Ambiguity
- [ ] Each requirement has a single valid interpretation
- [ ] Terms are defined — no jargon without shared meaning
- [ ] Quantitative where possible (not "fast" but "under 10ms")

### Completeness
- [ ] Edge cases covered (empty, nil, zero, max, concurrent)
- [ ] Error cases specified (what happens when things go wrong)
- [ ] No implicit assumptions left unstated

### Consistency
- [ ] No conflicting requirements
- [ ] No conflicting acceptance criteria
- [ ] Scope boundaries don't contradict requirements

### Feasibility
- [ ] Each requirement is technically achievable
- [ ] Each requirement is achievable within the stated constraints
- [ ] No requirement demands changes to out-of-scope systems

## Phase 4: Question the Captain

- [ ] Ambiguous requirements clarified via SendMessage
- [ ] Missing edge cases raised via SendMessage
- [ ] Implicit assumptions surfaced via SendMessage
- [ ] Conflicting criteria resolved via SendMessage
- [ ] Feasibility concerns raised via SendMessage
- [ ] All questions sent directly to Zidgel
- [ ] Responses received and incorporated
- [ ] OR: no questions needed — understanding confirmed from briefing

## Phase 5: Confirm Understanding

- [ ] Problem can be stated in one clear paragraph
- [ ] Each requirement is a testable assertion
- [ ] Scope boundaries are explicit
- [ ] Constraints are documented
- [ ] Acceptance criteria are measurable
- [ ] No ambiguity remains

## Phase 6: Compile Output

- [ ] Problem statement written
- [ ] Requirements listed as testable assertions
- [ ] Scope boundaries documented
- [ ] Constraints documented
- [ ] Resolved questions listed
- [ ] Remaining concerns flagged
- [ ] Output feeds directly into `evaluate`
