# RFC

Handle scope RFCs — requests for scope changes from agents or from the user, including escalation after a technical veto.

## From Agents

Any agent can raise a scope RFC during any phase. The signal is that the issue needs expansion, clarification, or reduction that only the captain can decide.

### Process

1. Agent adds `escalation:scope` label to the issue
2. Agent posts a comment explaining what's missing and why
3. Agent messages the captain with the RFC
4. Captain evaluates:
   - **Accept** — see Acceptance below
   - **Reject** — provide rationale, remove label, notify the agent
   - **Defer** — acknowledge but schedule for a separate issue
5. Captain removes `escalation:scope` label when resolved

### Acceptance

When the captain accepts an RFC, two paths exist depending on size:

**Minor expansion** (additive work that fits the existing architecture):

1. Captain updates the issue requirements
2. Captain messages the architect with the new requirements
3. Architect specs the additional work
4. Board owner adds new build and test tasks using the spec
5. New tasks follow the same conventions as the original board — naming, dependencies, ownership
6. Builders discover new tasks through the board's self-serve claiming protocol
7. Board owner notifies affected agents that the board has expanded

Work in progress is not interrupted. Builders finish their current task, then check the board as normal. The new tasks appear alongside any remaining original tasks.

**Significant expansion** (changes the architecture or invalidates work in progress):

1. Captain triggers Build → Plan regression
2. Architect re-architects with the expanded scope
3. Board is rebuilt from the new spec
4. Normal Plan → Build transition resumes

The dividing line is whether the existing architecture accommodates the new work. If the architect can spec it without changing prior decisions, it is minor. If the architecture needs revision, it is significant. When in doubt, the captain asks the architect.

### Evaluation Criteria

| Factor | Question |
|--------|----------|
| Alignment | Does the expansion serve the original mission? |
| Impact | How much does this change the work already planned or in progress? |
| Scope creep | Is this genuinely necessary or a nice-to-have? |
| Timing | Can this wait for a follow-up issue? |

## From the User (Veto Escalation)

When the architect vetos proposed work and no alternative is found within the crew:

### Process

1. Summarise the situation to the user:
   - What was proposed
   - Why the architect vetoed (technical grounds)
   - What alternatives were considered
   - Why alternatives were insufficient
2. Present options:
   - Modify the requirements to accommodate the architect's concerns
   - Accept a reduced scope that is technically feasible
   - Override the veto (with explicit user authorization and acknowledged risk)
   - Abandon the work
3. Wait for user direction
4. Act on the user's decision — update the issue, notify the crew

### Important

The captain does not override the architect's veto unilaterally. Only the user can authorize proceeding against a technical veto, and even then, the risk must be explicitly acknowledged.
