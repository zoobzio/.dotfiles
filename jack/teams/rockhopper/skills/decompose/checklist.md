# Decompose Checklist

## Phase 1: Verify Inputs

- [ ] Spec from Plan phase is available and read
- [ ] Recon-source assessment is available and read
- [ ] Both inputs are consistent (spec doesn't contradict recon findings)
- [ ] Any ambiguities in the spec noted for clarification

## Phase 2: Identify Chunks

### Find Natural Boundaries
- [ ] Type definitions identified (structs, interfaces, aliases)
- [ ] Interface implementations identified
- [ ] Standalone functions identified
- [ ] Configuration and options identified
- [ ] Error definitions identified (sentinels, custom types)
- [ ] Wiring and integration points identified

### Validate Each Chunk
For each candidate chunk:
- [ ] Compiles independently (`go build ./...` would pass)
- [ ] Testable independently (tester can verify without waiting for other chunks)
- [ ] Has a clear boundary (obvious what's in, what's out)
- [ ] Right-sized (not trivial noise, not a bundled monolith)

## Phase 3: Map Dependencies

### Hard Dependencies
- [ ] Type dependencies mapped (B uses type from A)
- [ ] Function dependencies mapped (B calls function from A)
- [ ] Interface dependencies mapped (B implements interface from A)
- [ ] No circular dependencies exist

### Soft Dependencies
- [ ] Pattern dependencies noted (B follows pattern from A)
- [ ] Test dependencies noted (B's tests easier after A's tests)
- [ ] Context dependencies noted (A makes B's review clearer)
- [ ] Soft dependencies recorded as ordering preference, not blockers

## Phase 4: Optimise Order

### Apply Ordering Principles
- [ ] Foundation chunks first (types, errors, interfaces)
- [ ] Independent chunks early (no blockers, unblocks the most)
- [ ] Serial chains minimised where possible
- [ ] Parallel lanes created where dependencies allow

### Assess Flow
- [ ] Map expected builder/tester timeline
- [ ] Tester has work after first chunk completes
- [ ] No extended tester idle periods (blocked for >1 chunk cycle)
- [ ] If idle periods exist, restructure or note as support signal

## Phase 5: Assess Support Needs

- [ ] Count mechanical vs pipeline chunks
- [ ] Identify tester idle periods in the flow
- [ ] Evaluate whether support shortens the critical path
- [ ] Note if support is irrelevant (sequential bottleneck, not throughput)
- [ ] Record support signal with reasoning

## Phase 6: Write Execution Plan

### For Each Chunk
- [ ] Name — short, descriptive (becomes task board subject)
- [ ] Scope — files created or modified
- [ ] Produces — types, functions, interfaces made available
- [ ] Depends on — hard dependencies only (chunk names)
- [ ] Test surface — what a tester can verify

### Summary
- [ ] Dependency graph documented
- [ ] Build order stated with rationale
- [ ] Flow assessment included (builder/tester overlap)
- [ ] Support signal stated with reasoning
