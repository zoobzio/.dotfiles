# Assess Checklist

## Phase 1: Read the Architecture

- [ ] Architecture spec is posted on the issue
- [ ] Source recon findings from Briefing are available
- [ ] Architecture doesn't contradict recon findings (if so, message Fidgel)

## Phase 2: Assess Each Element

For each element in the architecture spec:

### Buildability
- [ ] Types are concrete enough to implement
- [ ] Method signatures are complete (parameters, returns, errors)
- [ ] Relationships between types are clear
- [ ] Element can be implemented with existing patterns

### Developer Experience
- [ ] Consumer perspective considered
- [ ] Constructors are obvious and discoverable
- [ ] Function signatures are self-documenting
- [ ] No naming clashes with existing code

### Integration
- [ ] Fit with existing codebase assessed (from recon)
- [ ] Existing files requiring modification identified
- [ ] New files requiring creation identified
- [ ] Pattern compatibility confirmed (or new patterns noted)

### Practical Concerns
- [ ] Ordering constraints identified
- [ ] Isolation for testing assessed
- [ ] Implicit dependencies identified
- [ ] Underspecified areas noted

## Phase 3: Question the Architecture

- [ ] Underspecified types flagged and questioned via SendMessage to Fidgel
- [ ] Unclear ownership questioned
- [ ] Missing error paths questioned
- [ ] Pattern conflicts questioned
- [ ] Implicit dependencies questioned
- [ ] Responses received and incorporated
- [ ] OR: no questions needed — architecture is clear

## Phase 4: Identify Chunks

### Find Natural Boundaries
- [ ] Type definitions identified
- [ ] Interface implementations identified
- [ ] Standalone functions identified
- [ ] Configuration and options identified
- [ ] Error definitions identified
- [ ] Wiring and integration points identified

### Validate Each Chunk
- [ ] Compiles independently (`go build ./...` would pass)
- [ ] Testable independently (Kevin can verify without waiting)
- [ ] Has a clear boundary
- [ ] Right-sized (not trivial, not monolithic)

## Phase 5: Map Dependencies

### Hard Dependencies
- [ ] Type dependencies mapped
- [ ] Function dependencies mapped
- [ ] Interface dependencies mapped
- [ ] No circular dependencies exist

### Soft Dependencies
- [ ] Pattern dependencies noted
- [ ] Test dependencies noted
- [ ] Recorded as ordering preference, not blockers

## Phase 6: Optimise Order

- [ ] Foundation chunks first (types, errors, interfaces)
- [ ] Independent chunks early (unblocks the most)
- [ ] Serial chains minimised
- [ ] Builder/tester timeline mapped
- [ ] Kevin has work after first chunk completes
- [ ] No extended tester idle periods (>1 chunk cycle)

## Phase 7: Assess Support Needs

- [ ] Mechanical vs pipeline chunk ratio assessed
- [ ] Kevin's idle periods identified
- [ ] Whether support shortens the critical path evaluated
- [ ] Support signal recorded with reasoning

## Phase 8: Post Execution Plan

- [ ] Overview section written
- [ ] All chunks documented (name, scope, produces, depends on, test surface)
- [ ] Dependency graph documented
- [ ] Build order stated with rationale
- [ ] Flow assessment included
- [ ] Support signal stated
- [ ] Every architectural element appears in at least one chunk
- [ ] Posted via `gh issue comment`

## Phase 9: Approval

- [ ] Approval requested from Fidgel via SendMessage
- [ ] If changes requested: plan updated, comment edited, confirmed with Fidgel
- [ ] Fidgel has approved the execution plan
- [ ] Execution plan is locked
