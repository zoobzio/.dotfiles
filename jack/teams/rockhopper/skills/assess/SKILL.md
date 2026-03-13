# Assess Architecture

Ingest the architecture plan and prepare for implementation. Understand what's been designed, how it fits into existing code, and what it means for the execution plan.

## Philosophy

The architecture plan is the blueprint. Before decomposing it into chunks, the builder should understand it thoroughly — not just what it says, but what it implies. Every type has constructors. Every interface has implementations. Every error path has handling. The architecture plan may not spell all of this out, but the builder needs to know before committing to an execution plan.

Reading the architecture is not passive. It's the first act of building — probing the design for practical concerns that surface during implementation. If something in the architecture will be awkward to build, hard to wire, or unclear to consume — ask now. The architect can clarify intent, adjust the design, or confirm that the awkwardness is acceptable. A question during Plan costs nothing. A wrong assumption during Build costs a rewrite.

## Execution

1. Read checklist.md in this skill directory
2. Read the architecture plan comment on the issue
3. Cross-reference with the `source/recon` assessment
4. Walk through each architectural element
5. Raise questions via SendMessage to the architect
6. Produce an implementation assessment

## Specifications

### Inputs

Assessment requires two inputs:

| Input | Source | What it provides |
|-------|--------|-----------------|
| Architecture plan | Architect's issue comment (from Plan phase) | Types, interfaces, contracts, dependencies, constraints |
| Recon assessment | `source/recon` output | Existing patterns, conventions, integration points |

If either input is missing, stop. Assessing architecture without the plan is guesswork. Assessing without recon ignores what's already there.

### Reading the Architecture

The architecture plan typically contains:

| Element | What to look for |
|---------|-----------------|
| Types | New structs, interfaces, type aliases — are they clear and well-bounded? |
| Contracts | Interface definitions, method signatures — are they implementable? |
| Dependencies | What imports what, internal vs external — does this match existing patterns? |
| Error handling | Sentinel errors, custom types, wrapping strategy — is it consistent? |
| Configuration | Options, defaults, validation — is the consumer experience clean? |
| Constraints | What's explicitly out of scope, what must not change |

### Per-Element Assessment

For each architectural element, determine:

#### Buildability
- Can this be implemented with the existing codebase patterns?
- Are the types concrete enough to write code from?
- Are method signatures complete (parameters, returns, error conditions)?
- Is the relationship between types clear (who owns what, who calls what)?

#### Developer Experience
- How does this feel from the consumer's perspective?
- Are constructors obvious? Is the API discoverable?
- Can someone read a function signature and know what it does?
- Are there naming clashes or confusing overlaps with existing code?

#### Integration
- How does this fit into what already exists (from recon)?
- Which existing files need modification?
- Which new files need creation?
- Do existing patterns cover this, or does the architecture introduce new patterns?

#### Practical Concerns
- Are there ordering constraints? (type A must exist before type B can be implemented)
- Are there pieces that will be hard to test in isolation?
- Are there implicit dependencies the architecture doesn't state?
- Is anything underspecified that the builder would have to guess at?

### Questioning the Architecture

The architecture is a design, not a mandate to guess from. If something is unclear, incomplete, or raises practical concerns — ask.

**Ask the architect directly via SendMessage.** Do not guess. Do not assume. Do not wait until Build to discover the answer.

Questions worth asking:

| Signal | Question |
|--------|----------|
| Underspecified type | "Type X has methods A and B — does it also need C for interface Y?" |
| Unclear ownership | "Who constructs type X — the consumer or an internal factory?" |
| Missing error path | "Function X returns error — what conditions trigger it?" |
| Pattern conflict | "The architecture uses pattern A, but existing code uses pattern B — which takes precedence?" |
| Implicit dependency | "Type X references type Y which doesn't exist yet — is that in scope or assumed?" |
| Consumer experience | "The constructor takes 5 required parameters — should this use the options pattern?" |
| Naming concern | "Type X shares a name prefix with existing type Y — is that intentional?" |

Do not stockpile questions. Ask as they arise. Short, specific messages. The architect can clarify incrementally.

### Implementation Assessment

After assessing all elements, produce an assessment that maps the architecture to buildable work:

#### Per-Element Build Map

For each architectural element:

| Field | Content |
|-------|---------|
| Element | Type, interface, function, etc. from the architecture |
| Files affected | New files to create, existing files to modify |
| Pattern | Which existing pattern applies (or if a new pattern is introduced) |
| Dependencies | What must exist before this element can be implemented |
| Practical concerns | Anything that will affect decomposition or build order |

#### Ordering Constraints

Identify the natural build sequence:
- What must exist first (foundational types, interfaces, errors)
- What can be built in parallel (independent types, standalone functions)
- What comes last (wiring, integration, configuration that ties things together)

#### Gap Analysis

Identify what the architecture doesn't cover that the builder will encounter:
- Constructors implied but not specified
- Validation logic implied but not detailed
- Error wrapping strategy implied but not defined
- Test helper implications (types that consumers will need help constructing)

## Output

An implementation assessment containing:
- **Per-element build map** — files, patterns, dependencies, concerns for each element
- **Ordering constraints** — what must come first, what's parallel, what's last
- **Gap analysis** — what's implied but unspecified
- **Open questions** — anything raised via SendMessage that hasn't been resolved yet
