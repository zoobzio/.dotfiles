# Assess

Read the architecture spec, break the work into chunks, determine the build order, assess whether support is needed, and post the execution plan. This is Midgel's half of Plan.

## Philosophy

The architecture spec describes what to build. Assessment determines how the work flows — what gets built first, what depends on what, when testing can begin, and whether the workload warrants support from Fidgel during Build.

A poor assessment serialises the entire team: the builder works alone while the tester waits. A good assessment creates parallel lanes where building and testing overlap, keeps blockers short, and surfaces support needs before they become bottlenecks.

Every chunk must compile on its own. Every chunk must be testable on its own. If a chunk can't be verified independently, it's not a chunk — it's a fragment of something larger that hasn't been properly decomposed.

## Execution

1. Read checklist.md in this skill directory
2. Read Fidgel's architecture spec on the issue
3. Cross-reference with source recon findings from Briefing
4. Walk through each architectural element for buildability and practical concerns
5. Raise questions via SendMessage to Fidgel
6. Break the work into independently-compilable, independently-testable chunks
7. Order chunks for maximum builder/tester overlap
8. Assess whether the workload warrants support from Fidgel during Build
9. Post the execution plan to the issue
10. Request approval from Fidgel via SendMessage

## Specifications

### Reading the Architecture

The architecture spec typically contains:

| Element | What to look for |
|---------|-----------------|
| Types | New structs, interfaces, type aliases — are they clear and well-bounded? |
| Contracts | Interface definitions, method signatures — are they implementable? |
| Dependencies | What imports what, internal vs external — does this match existing patterns? |
| Error handling | Sentinel errors, custom types, wrapping strategy — is it consistent? |
| Configuration | Options, defaults, validation — is the consumer experience clean? |
| Constraints | What's explicitly out of scope, what must not change |

Cross-reference with source recon from Briefing. If the architecture contradicts what exists in the codebase, message Fidgel before proceeding.

### Per-Element Assessment

For each architectural element:

| Aspect | Assessment |
|--------|------------|
| Buildability | Can this be implemented with existing patterns? Are types concrete enough? Are signatures complete? |
| Developer experience | How does this feel from the consumer's perspective? Are constructors obvious? |
| Integration | How does this fit into what already exists? Which files are affected? |
| Practical concerns | Ordering constraints? Hard to test in isolation? Implicit dependencies? Underspecified? |

### Questioning the Architecture

If something is unclear, incomplete, or raises practical concerns — ask Fidgel via SendMessage. Do not guess. Do not wait until Build to discover the answer.

| Signal | Question |
|--------|----------|
| Underspecified type | "Type X has methods A and B — does it also need C for interface Y?" |
| Unclear ownership | "Who constructs type X — the consumer or an internal factory?" |
| Missing error path | "Function X returns error — what conditions trigger it?" |
| Pattern conflict | "The architecture uses pattern A, but existing code uses pattern B — which takes precedence?" |
| Implicit dependency | "Type X references type Y which doesn't exist yet — is that in scope or assumed?" |

### Identifying Chunks

A chunk is a unit of work that:

1. **Compiles independently** — `go build ./...` passes after this chunk alone
2. **Is testable independently** — Kevin can write meaningful tests without waiting for other chunks
3. **Has a clear boundary** — it's obvious what's in the chunk and what isn't
4. **Produces visible progress** — completing it moves the project forward

Natural boundaries in the spec:

| Boundary type | Example |
|---------------|---------|
| Type definitions | A new struct and its constructor |
| Interface implementations | A type satisfying an interface contract |
| Standalone functions | Pure logic with clear inputs and outputs |
| Configuration | Options, defaults, validation |
| Error definitions | Sentinel errors, custom error types |
| Wiring | Connecting components (often depends on the components) |

#### Chunk Sizing

Too small: trivial work that creates board noise. A single constant definition is not a chunk.

Too large: multiple concerns bundled together that force the tester to wait. If a chunk takes longer to build than the previous chunk takes to test, the tester is idle.

Right-sized: contains one coherent concern, compiles, and can be tested without knowledge of chunks that haven't been built yet.

### Dependency Analysis

#### Hard Dependencies

Chunk B cannot compile without chunk A — real blockers:

- B uses a type defined in A
- B calls a function defined in A
- B implements an interface defined in A

#### Soft Dependencies

Chunk B would benefit from A being done first, but can compile without it. These inform ordering preference but do not create task board blocks.

### Optimising Build Order

The goal is **maximum overlap between building and testing**. Kevin should have work available as early as possible and should rarely be idle.

Principles:

1. **Foundation first** — types, errors, and interfaces before implementations
2. **Independent chunks early** — chunks with no dependencies unblock the most downstream work
3. **Testing pipeline** — after the first chunk is complete, Kevin should always have something to test
4. **Avoid long serial chains** — restructure where possible so some chunks are parallel

### Support Assessment

After ordering, assess whether the workload warrants Fidgel entering support mode during Build:

| Signal | Implication |
|--------|-------------|
| Many mechanical chunks, few pipeline chunks | Fidgel's build support reduces tester idle time |
| Kevin blocked for extended periods | Fidgel's test support on earlier chunks while Midgel continues |
| Large chunk count (>6 build tasks) | Consider whether support accelerates the critical path |
| All chunks are sequential | Support won't help — the bottleneck is dependency ordering, not throughput |

State whether support is warranted and why. This is Midgel's recommendation — the team decides during Build.

### Execution Plan Format

Post to the issue:

```markdown
## Execution Plan

### Overview

Brief summary — chunk count, dependency shape, expected flow.

### Chunks

#### 1. chunk-name

- **Scope:** files created or modified
- **Produces:** types, functions, interfaces made available
- **Depends on:** previous chunks (or none)
- **Test surface:** what Kevin can verify after this chunk

#### 2. chunk-name

...

### Dependency Graph

Which chunks block which.

### Build Order

Recommended sequence with rationale.

### Flow

Expected builder/tester overlap:
- When test work begins
- Where idle periods exist

### Support Signal

Whether the workload warrants support from Fidgel during Build, and why.
```

### Approval

After posting, request approval from Fidgel via SendMessage. Fidgel knows the design intent and can spot where the decomposition misaligns with the architecture.

If changes are requested: update the execution plan, edit the issue comment, confirm with Fidgel. Repeat until approved.

Do not proceed past this skill without approval. The execution plan is a two-party agreement.

## Output

An approved issue comment containing:
- Per-chunk details (scope, produces, depends on, test surface)
- Dependency graph
- Build order with rationale
- Flow assessment (builder/tester overlap)
- Support signal with reasoning
