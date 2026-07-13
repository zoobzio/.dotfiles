# Plan

See the whole run before you make the first move.

## Design the Approach

Based on what you learned in research, decide how to solve the problem:

- What files will you create, modify, or delete?
- What is the order of operations — what needs to happen first?
- What patterns does the codebase already use for this kind of change? Follow them.
- What are the trade-offs? If there are multiple valid approaches, pick one and know why.

## Define the Tests

Before you write code, know how you will prove it works:

- What new tests are needed?
- What existing tests need updating?
- What edge cases should be covered?
- How will you verify the change does not break existing behavior?

## Scope the PR

A good PR has a clear boundary:

- What is in this PR and what is not?
- If the issue is large, can it be broken into smaller PRs? Smaller is better.
- What will the PR description say? If you cannot summarize the change in a sentence, the scope may be too broad.

## Check the Plan

Before implementing, sanity check:

- [ ] The approach follows existing codebase patterns
- [ ] No unnecessary dependencies introduced
- [ ] The change is minimal — only what the issue requires, no extras
- [ ] The test plan covers the requirements
- [ ] The PR scope is clear and bounded
- [ ] You can see the whole run — no gaps, no unknowns

If anything is unclear, go back to research. If the plan is solid, proceed to implement.
