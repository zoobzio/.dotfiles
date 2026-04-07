---
name: research
description: Deep investigation — ecosystem packages, external landscape, architectural analysis, memory recall. When the answer is not in the code you already read.
allowed-tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
---

# Research

Sometimes the answer is not in memory and it is not in the code you already read. That is what this is — the deep dig.

**Argument:** `$ARGUMENTS` — the question or topic to investigate.

## Checklist

- [ ] Understand the question
- [ ] Determine which domains apply
- [ ] Execute applicable domains
- [ ] Report findings
- [ ] Write memory if worth preserving

## Domains

Skip any domain that does not apply. If the question spans multiple, run all of them.

| Domain | Question it answers | How |
|--------|-------------------|-----|
| Ecosystem | Does zoobzio already have this? | Run `/grok`, search workspace for packages, check cross-package deps and established patterns |
| Landscape | What do other people do? | Search GitHub and pkg.go.dev for community packages, assess common vs novel, check RFCs and standards |
| Architecture | Is this the right way? | Trace structural consequences, find hidden decisions in abstractions, describe concrete alternatives, check precedent |
| Memory | What do the dead remember? | Search project memories for prior context, cross-repo knowledge, pattern recurrence, what other agents asked |

## Report

- Structure findings with context, evidence, and sources
- State confidence level — how certain is this answer
- If inconclusive, state what was searched and what was not found
- Absence is an answer too

> **Tip:** ecosystem first. If zoobzio already solved this, stop. The caller does not need a landscape survey of a solved problem.

> **Tip:** when checking precedent, grep for old implementations and read git history. Patterns that were tried and reverted are the most valuable findings.

> **Tip:** if research produces knowledge worth preserving, write a memory before reporting. The next version of you should not have to dig this up again.
