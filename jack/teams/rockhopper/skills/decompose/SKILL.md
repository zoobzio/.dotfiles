# Decompose

Break a spec into discrete, independently-testable chunks and determine the optimal build order. The output drives the task board and sets the tempo for the entire Build phase.

## Philosophy

A spec describes what to build. Decomposition determines how the work flows — what gets built first, what depends on what, and when testing can begin. A poor decomposition serialises the entire team: the builder works alone while the tester waits. A good decomposition creates parallel lanes where building and testing overlap, keeps blockers short, and surfaces support needs before they become bottlenecks.

Every chunk must compile on its own. Every chunk must be testable on its own. If a chunk can't be verified independently, it's not a chunk — it's a fragment of something larger that hasn't been properly decomposed.

## Execution

1. Read checklist.md in this skill directory
2. Ingest the spec and source/recon assessment
3. Identify natural boundaries in the work
4. Determine dependencies between chunks
5. Optimise for parallel flow
6. Assess support needs
7. Produce the execution plan

## Specifications

### Inputs

Decomposition requires two inputs:

| Input | Source | What it provides |
|-------|--------|-----------------|
| Spec | Architecture (from Plan phase) | What to build, contracts, constraints |
| Recon assessment | `source/recon` output | What exists, established patterns, integration points |

If either input is missing, stop. A decomposition without a spec is guesswork. A decomposition without recon ignores what's already there.

### Identifying Chunks

A chunk is a unit of work that:

1. **Compiles independently** — `go build ./...` passes after this chunk alone
2. **Is testable independently** — a tester can write meaningful tests without waiting for other chunks
3. **Has a clear boundary** — it's obvious what's in the chunk and what isn't
4. **Produces visible progress** — completing it moves the project forward in a way the board reflects

#### Natural Boundaries

Look for these seams in the spec:

| Boundary type | Example |
|---------------|---------|
| Type definitions | A new struct and its constructor |
| Interface implementations | A type satisfying an interface contract |
| Standalone functions | Pure logic with clear inputs and outputs |
| Configuration | Options, defaults, validation |
| Error definitions | Sentinel errors, custom error types |
| Wiring | Connecting components (often depends on the components) |

#### Chunk Sizing

Too small: trivial work that creates board noise without meaningful progress. A single constant definition is not a chunk.

Too large: multiple concerns bundled together that force the tester to wait for everything before testing anything. If a chunk takes longer to build than the previous chunk takes to test, the tester is idle.

Right-sized: contains one coherent concern, compiles, and can be tested without knowledge of chunks that haven't been built yet.

### Dependency Analysis

Once chunks are identified, map what depends on what:

#### Hard Dependencies

Chunk B cannot compile without chunk A. These are real blockers:

- B uses a type defined in A
- B calls a function defined in A
- B implements an interface defined in A

#### Soft Dependencies

Chunk B would benefit from A being done first, but can compile without it:

- B follows a pattern established by A
- B's tests are easier to write after A's tests exist
- A provides context that makes B's review clearer

Soft dependencies inform ordering preference but do not create task board blocks.

### Optimising Build Order

The goal is **maximum overlap between building and testing**. The tester should have work available as early as possible and should rarely be idle waiting for the builder.

#### Principles

1. **Foundation first** — Types, errors, and interfaces before implementations
2. **Independent chunks early** — Chunks with no dependencies unblock the most downstream work
3. **Testing pipeline** — After the first chunk is complete, the tester should always have something to test
4. **Avoid long serial chains** — If chunks A → B → C → D are all sequential, the tester waits for each one. Restructure where possible so some chunks are parallel

#### Flow Assessment

Map the expected timeline:

```
Builder:  [chunk-1] [chunk-2] [chunk-3] [chunk-4]
Tester:        [test-1] [test-2] [test-3] [test-4]
```

Good: building and testing overlap. The tester picks up test-1 while the builder starts chunk-2.

```
Builder:  [chunk-1] [chunk-2] [chunk-3 .............]
Tester:                                  [test-1] [test-2] [test-3]
```

Bad: the tester is idle until chunk-3 finishes because everything depends on everything.

If the flow shows the tester blocked for more than one chunk cycle, restructure. Pull independent work forward. Split large chunks.

### Support Assessment

After ordering, assess whether the workload warrants support:

| Signal | Implication |
|--------|-------------|
| Many mechanical chunks, few pipeline chunks | Builder may need support — shared workload reduces tester idle time |
| Tester blocked for extended periods | Test support may help — a second tester on earlier chunks while the builder continues |
| Large chunk count (>6 build tasks) | Consider whether support accelerates the critical path |
| All chunks are sequential | Support won't help — the bottleneck is dependency ordering, not throughput |

Support is a protocol decision, not a decomposition decision. The decomposition surfaces the signal. The team decides.

### Chunk Description Format

Each chunk in the execution plan should contain:

| Field | Content |
|-------|---------|
| Name | Short descriptive name (becomes the task board subject) |
| Scope | What files are created or modified |
| Produces | What this chunk makes available (types, functions, interfaces) |
| Depends on | Which chunks must complete first (hard dependencies only) |
| Test surface | What a tester can verify after this chunk |

## Output

An execution plan containing:

- **Chunk list** — each chunk with name, scope, produces, depends on, and test surface
- **Dependency graph** — which chunks block which, visualised as a simple list or diagram
- **Build order** — the recommended sequence, optimised for parallel flow
- **Flow assessment** — expected builder/tester overlap, idle periods identified
- **Support signal** — whether the workload shape suggests requesting support, and why
