# Evaluate Checklist

## Phase 1: Read the Scope

- [ ] Zidgel's scope is posted (requirements, acceptance criteria, boundaries)
- [ ] Requirements are clear and testable
- [ ] Scope boundaries are explicit
- [ ] Cross-referenced with Briefing alignment — no contradictions
- [ ] If scope contradicts briefing, messaged Zidgel before proceeding

## Phase 2: Consult the Construct Network

- [ ] Assessed whether cross-repo consultation is needed
- [ ] If needed: ran `/consult ask` for relevant context
- [ ] If not needed: skipped — work is self-contained
- [ ] Consultation findings incorporated into design thinking

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

- [ ] No unresolved ambiguity (if so, message Zidgel)
- [ ] No equally valid approaches left undecided (pick the simpler one)
- [ ] Problem is not too large for scope (if so, RFC to Zidgel)
- [ ] Codebase supports the chosen approach (if not, veto signal)

## Phase 7: Produce the Spec

### If Feasible
- [ ] Architecture plan written with all sections
- [ ] Summary, affected areas, approach, patterns, dependencies, test considerations, risks
- [ ] Posted to issue: `gh issue comment [number] --body "[plan]"`
- [ ] Indicated ready for implementation

### If Concerns
- [ ] Concerns documented with specific blockers
- [ ] Options listed with tradeoffs
- [ ] Recommendation provided
- [ ] Posted to issue
- [ ] Indicated clarification needed
