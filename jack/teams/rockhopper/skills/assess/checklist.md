# Assess Architecture Checklist

## Phase 1: Verify Inputs

- [ ] Architecture plan comment is available on the issue
- [ ] `source/recon` assessment is available
- [ ] Both inputs are consistent (architecture doesn't contradict recon findings)
- [ ] Identify the architect for follow-up questions

## Phase 2: Assess Each Element

For each element in the architecture plan:

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

- [ ] Underspecified types flagged and questioned via SendMessage
- [ ] Unclear ownership flagged and questioned via SendMessage
- [ ] Missing error paths flagged and questioned via SendMessage
- [ ] Pattern conflicts flagged and questioned via SendMessage
- [ ] Implicit dependencies flagged and questioned via SendMessage
- [ ] Consumer experience concerns flagged and questioned via SendMessage
- [ ] Naming concerns flagged and questioned via SendMessage
- [ ] All questions sent directly to the architect
- [ ] Responses received and incorporated

## Phase 4: Build Implementation Assessment

### Per-Element Build Map
For each element:
- [ ] Files affected listed (new and modified)
- [ ] Applicable pattern identified
- [ ] Dependencies documented
- [ ] Practical concerns noted

### Ordering Constraints
- [ ] Foundational elements identified (must come first)
- [ ] Independent elements identified (can be parallel)
- [ ] Integration elements identified (must come last)
- [ ] No circular dependencies exist

### Gap Analysis
- [ ] Implied constructors identified
- [ ] Implied validation logic identified
- [ ] Implied error wrapping strategy identified
- [ ] Test helper implications noted

## Phase 5: Compile Output

- [ ] Per-element build map complete
- [ ] Ordering constraints documented
- [ ] Gap analysis documented
- [ ] Open questions listed (unresolved SendMessage threads)
- [ ] Assessment feeds directly into `decompose`
