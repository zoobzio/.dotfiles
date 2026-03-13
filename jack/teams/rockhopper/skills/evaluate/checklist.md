# Evaluate Checklist

## Phase 1: Verify Input

- [ ] Confirmed understanding from `analyze` is available
- [ ] Problem statement is clear and unambiguous
- [ ] Requirements are stated as testable assertions
- [ ] Scope boundaries and constraints are documented

## Phase 2: Research

### Targeted Investigation
- [ ] Identify what research is needed (not all applies to every problem)
- [ ] Codebase patterns and ecosystem context examined (`/grok`) — if relevant
- [ ] Source landscape surveyed (`source/recon`) — if relevant
- [ ] Documentation landscape surveyed (`docs/recon`) — if relevant
- [ ] Research is targeted, not exhaustive

## Phase 3: Identify Forces

- [ ] Existing patterns identified (consistency pressure)
- [ ] Performance constraints identified (if applicable)
- [ ] API surface constraints identified (backward compatibility, consumer impact)
- [ ] Complexity budget assessed
- [ ] Test surface requirements identified
- [ ] Ecosystem position assessed (dependent packages, consumers)
- [ ] Conflicting forces noted with which takes precedence

## Phase 4: Consider Approaches

### For Each Candidate
- [ ] Requirements satisfaction assessed
- [ ] Pattern consistency assessed
- [ ] Complexity cost assessed
- [ ] Test surface assessed
- [ ] Risk assessed
- [ ] Ecosystem impact assessed

### Decision
- [ ] Approach chosen with rationale
- [ ] Rejected alternatives noted with reasons (for non-trivial problems)
- [ ] OR: single obvious approach noted with justification

## Phase 5: Make Design Decisions

- [ ] Approach decided and stated
- [ ] Decomposition decided (major components identified)
- [ ] Pattern choices made (which existing patterns to follow)
- [ ] Tradeoffs decided with rationale
- [ ] Constraints decided (internal vs public, scope limits)
- [ ] Risk mitigations identified
- [ ] Each decision states what and why

## Phase 6: Check for Stalls

- [ ] No unresolved ambiguity (if so, return to `analyze`)
- [ ] No equally valid approaches left undecided (pick the simpler one)
- [ ] Problem is not too large for scope (if so, RFC to Zidgel)
- [ ] Codebase supports the chosen approach (if not, veto signal)

## Phase 7: Compile Output

- [ ] Forces documented
- [ ] Chosen approach stated with rationale
- [ ] Key decisions listed with reasons
- [ ] Rejected alternatives noted (if applicable)
- [ ] Risks identified
- [ ] Open items for `architect` listed
- [ ] Output feeds directly into `architect`
