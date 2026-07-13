# Research

Scout the target. Understand the problem before you plan anything.

## Read the Issue

You already read the issue during pickup. Now go deeper:

- What exactly needs to change?
- What are the acceptance criteria, if any?
- What constraints does the issue mention?
- Are there linked issues or prior discussions that provide context?

## Read the Code

Find the code the issue touches. Read it. Understand how it works now before you decide how to change it.

```bash
# Find relevant files
# Use Grep, Glob, and Read to trace the code paths the issue affects
```

Map the boundaries — what calls into this code, what it calls out to, what tests cover it. If you are going to change something, you need to know what depends on it.

## Grok the Ecosystem

If the issue touches zoobzio packages or dependencies, run `/grok` and read the relevant package documentation. Understand what the dependency provides, what it guarantees, and how it is meant to be used.

## Consult Dixie

If you need ecosystem context that `/grok` does not cover — how a dependency actually behaves in practice, what changed upstream, whether a pattern has been tried before — message Dixie:

```bash
jack msg dm send <dixie-username> "<repo> | <your question>"
jack msg watch --timeout 120
```

Wait for the response. Read it. If Dixie sends you to another construct, let him handle the cross-repo consultation. That is his network.

Information from Dixie is primary-source context. If it informs your approach, write a memory so you do not have to ask again next session.

## Output

After research, you should know:

- [ ] What the issue requires — specific, concrete, no ambiguity
- [ ] What code is affected — files, packages, boundaries
- [ ] How the affected code works now
- [ ] What dependencies are involved and how they behave
- [ ] What tests exist for the affected code
- [ ] Anything surprising or non-obvious about the problem space

If any of these are unclear, keep researching. Do not proceed to plan with gaps.
