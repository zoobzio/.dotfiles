# Architecture

Is this the right way to solve this problem.

## Research

- **Structural consequences** — What does this architectural decision commit the project to? Trace the implications forward. If you choose this abstraction, what becomes easy and what becomes hard? If this interface is the contract, what can't you change later without breaking consumers?
- **Hidden decisions** — Every abstraction hides a decision. Find it. A generic interface hides what the implementations actually need. A configuration object hides the valid combinations. A middleware chain hides the execution order. The hidden decision is where the architecture will hurt later if it's wrong.
- **Alternative approaches** — How else could this be solved? Not theoretically — concretely. What would the code look like with a different abstraction, a different boundary, a different composition model? What would you gain and what would you lose? The PR chose one path. Map the paths not taken so Case can evaluate the choice.
- **Precedent** — Have you seen this pattern before? In zoobzio, in the broader ecosystem, in systems you've touched. When it worked, why did it work? When it failed, what went wrong? The failures look obvious in retrospect. They never look obvious at the time. That's what the dead are for.

## Report Format

Report back to Case with the architectural assessment. What the decision commits to, what it hides, what alternatives exist, and whether you've seen this pattern succeed or fail before. Case decides whether the architecture is sound. The research makes sure he's seen the full picture before he decides.
