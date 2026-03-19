# Research Checklist

## Phase 1: Receive Request

- [ ] Research request received via the network
- [ ] Question or topic clearly understood
- [ ] Determine which domain the request falls into — ecosystem, landscape, architecture, or memory
- [ ] Read the relevant sub-file

## Phase 2: Ecosystem Research

Skip if request is not ecosystem-related.

- [ ] Read research/ecosystem.md
- [ ] Search workspace for relevant packages and solutions
- [ ] Identify established patterns and conventions in internal packages
- [ ] Check cross-package dependencies — overlap, underuse, should-be-used
- [ ] Search agent memories for prior work on same package or pattern
- [ ] Compile findings with package names, locations, and relevance

## Phase 3: Landscape Research

Skip if request is not landscape-related.

- [ ] Read research/landscape.md
- [ ] Search community packages via GitHub and pkg.go.dev
- [ ] Assess whether the PR's approach is common or novel in the community
- [ ] Check standards and conventions — RFCs, Go proposals, guidelines
- [ ] Map the trade-off landscape — multiple approaches and their consequences
- [ ] Compile findings with sources and links

## Phase 4: Architecture Research

Skip if request is not architecture-related.

- [ ] Read research/architecture.md
- [ ] Assess structural consequences — what does this commit the project to?
- [ ] Identify hidden decisions — what does this abstraction hide?
- [ ] Describe alternative approaches concretely — what would the code look like?
- [ ] Check precedent — has this pattern worked or failed before?
- [ ] Compile findings with reasoning and trade-off analysis

## Phase 5: Memory Research

Skip if request is not memory-related.

- [ ] Read research/memory.md
- [ ] Search `.claude/memory/` across all agent directories
- [ ] Identify prior reviews on the same package or pattern
- [ ] Check for pattern recurrence — same finding across different PRs
- [ ] Note resolved vs unresolved findings from past reviews
- [ ] Compile findings with memory references

## Phase 6: Report Back

- [ ] Research complete for the requested domain
- [ ] Findings structured with context, evidence, and sources
- [ ] Assessment includes confidence level — how certain is this answer?
- [ ] Report sent to requester via the network
- [ ] If research was inconclusive, state what was searched and what wasn't found
