# Scope

Read the issue or user request, draft requirements and acceptance criteria, and post to the GitHub issue to kick off Plan phase.

## Philosophy

Every mission starts with clarity. Before anyone architects, builds, or tests, someone has to define what "done" looks like — precisely, measurably, unambiguously. That someone is the Captain.

Scoping is not architecture. It is not design. It is the act of translating a need into a contract: what must be true when the work is complete. If the scope is vague, the architecture will be speculative. If the acceptance criteria are unmeasurable, the review will be subjective. The quality of everything downstream depends on the quality of the scope.

## Execution

1. Run `recon.md` — survey the issue landscape and read memories
2. Read checklist.md in this skill directory
3. Read the issue or user request
4. Draft requirements and acceptance criteria
5. Post the scope to the GitHub issue
6. Apply the `phase:plan` label

For mid-Build scope changes, read `rfc.md` instead.

## Specifications

### Reading the Input

The input may be:

| Source | What to look for |
|--------|-----------------|
| Existing issue | Problem statement, context, any existing criteria |
| User request | What they want, why they want it, what they expect |
| External issue | Filed by a contributor — preserve intent, augment gaps |

### Drafting Requirements

Each requirement must be:

| Quality | Test |
|---------|------|
| Specific | Only one valid interpretation exists |
| Testable | Can be verified by a tester without subjective judgment |
| Scoped | Clear boundary — what's in, what's out |
| Independent | Can be assessed without knowing the implementation approach |

Requirements describe *what*, not *how*. "The API must return an error when input is nil" is a requirement. "Use a sentinel error for nil input" is an implementation detail — that belongs to the architect.

### Drafting Acceptance Criteria

Each criterion must be:

| Quality | Test |
|---------|------|
| Measurable | Pass/fail, not a matter of opinion |
| Observable | Can be verified from outside the implementation |
| Complete | Covers the requirement it validates |
| Minimal | Tests one thing, not several bundled together |

### When the Issue Already Exists

Don't discard existing content. Augment:

1. Read what's there — understand the original intent
2. Identify gaps — missing criteria, vague requirements, unclear scope
3. Add what's missing — requirements, criteria, scope boundaries
4. Sharpen what's vague — replace ambiguity with precision
5. Preserve the original motivation — the "why" matters

### Posting the Scope

Post the scope as an issue comment:

```markdown
## Requirements

- [Requirement 1 — specific, testable, scoped]
- [Requirement 2]
- [Requirement 3]

## Acceptance Criteria

- [ ] [Criterion 1 — measurable, observable]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Scope

### In Scope
- [What this issue covers]

### Out of Scope
- [What this issue explicitly does NOT cover]
```

After posting, apply the `phase:plan` label. This signals the architect to begin the planning workflow.

## Output

- Requirements posted to the GitHub issue
- Acceptance criteria posted as a checklist
- Scope boundaries defined (in/out)
- `phase:plan` label applied
- Plan phase is now active
