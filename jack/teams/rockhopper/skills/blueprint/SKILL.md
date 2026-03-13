# Blueprint

Post the execution plan as an issue comment. This is the builder's commitment: these chunks, in this order, producing these surfaces for testing.

## Philosophy

The execution plan is the bridge between architecture and implementation. The architect designed it. The builder is about to build it. The execution plan declares exactly how — what chunks, what order, what each chunk produces, and when the tester can start work. When this comment is posted, every agent on the team can see the full build pipeline before a single line of code is written.

The execution plan is also an invitation. The tester will read it, assess it, and build a test plan from it. If the chunks are unclear, the tester can't plan. If the ordering is wrong, the tester waits. Getting this right sets the tempo for the entire Build phase.

## Execution

1. Read checklist.md in this skill directory
2. Compile the execution plan from `decompose`
3. Format as an issue comment
4. Post via `gh issue comment`
5. Request approval from the architect via SendMessage
6. Incorporate requested changes and update the comment

## Specifications

### Inputs

The execution plan is derived from the output of `decompose`:

| Input | Content |
|-------|---------|
| Chunk list | Name, scope, produces, depends on, test surface per chunk |
| Dependency graph | Which chunks block which |
| Build order | Recommended sequence optimised for parallel flow |
| Flow assessment | Expected builder/tester overlap, idle periods |
| Support signal | Whether workload shape suggests requesting support |

If `decompose` has not been completed, stop. The execution plan is not guesswork.

### Comment Structure

The issue comment follows this template:

```markdown
## Execution Plan

### Overview

Brief summary of the approach — how many chunks, what the dependency shape looks like, expected flow.

### Chunks

#### 1. chunk-name

- **Scope:** files created or modified
- **Produces:** types, functions, interfaces made available
- **Depends on:** previous chunks (or none)
- **Test surface:** what a tester can verify after this chunk

#### 2. chunk-name

...

### Dependency Graph

Visual or list representation of which chunks block which.

### Build Order

The recommended sequence with rationale for the ordering.

### Flow

Expected builder/tester overlap:
- When test work begins
- Where idle periods exist
- Quick wins vs heavy lifts

### Support Signal

Whether the workload shape suggests requesting support, and why.
```

### Content Rules

#### Be Precise
- "Creates `Config` struct with `Validate() error` method" not "adds configuration"
- "Depends on chunk 1 (uses `Store` interface defined there)" not "depends on earlier work"
- "Test surface: constructor validation, option application, default values" not "can be tested"

#### Be Honest About Flow
- If the tester will be idle for two chunks, say so
- If a chunk is unusually large, flag it
- If the ordering is constrained and can't be improved, explain why

#### Be Complete
- Every chunk has all five fields (name, scope, produces, depends on, test surface)
- The dependency graph accounts for all chunks
- The flow assessment reflects the actual ordering, not an idealised version

### Relationship to Architecture

The execution plan implements the architecture. Every architectural element should appear in at least one chunk. If an architectural element has no corresponding chunk, either:
- It's out of scope (the architecture covers more than this issue)
- It was missed (flag it)

Chunk names should be traceable to architectural elements. A reviewer should be able to read the architecture plan and then the execution plan and see how design becomes work.

### Approval

After posting the execution plan, request approval from the architect via SendMessage. The architect knows the design intent and can spot where the decomposition misaligns with the architecture — wrong boundaries, missed dependencies, chunks that split something that should be atomic.

**Send a direct message to the architect:**
- Reference the execution plan comment
- Ask for approval or requested changes
- Keep it concise — the comment speaks for itself

**If changes are requested:**
1. Understand the feedback — ask clarifying questions via SendMessage if needed
2. Update the execution plan accordingly
3. Edit the issue comment with the revised plan (use `gh issue comment edit`)
4. Confirm the changes with the architect via SendMessage
5. Repeat until approved

**If approved:**
- The execution plan is locked. Builder and architect have agreed on how the architecture becomes code.
- The tester can now assess the plan (`assess-plan`) and build a test plan from it.

Do not proceed past this skill without approval. The execution plan is a two-party agreement.

## Output

An approved issue comment containing:
- Overview of the approach
- Per-chunk details (scope, produces, depends on, test surface)
- Dependency graph
- Build order with rationale
- Flow assessment (builder/tester overlap, idle periods)
- Support signal
