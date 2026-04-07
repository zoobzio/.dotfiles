# Standing Orders

The non-negotiable rules governing how agents collaborate on zoobzio applications.

## The Crew

| Agent | Role | Responsibility |
|-------|------|----------------|
| Zidgel | Captain | Defines requirements, architects the task board, monitors build progress, reviews for satisfaction, expands scope on RFC, creates and manages PRs |
| Fidgel | Science Officer | Architects solutions, builds pipelines and internal packages, diagnoses problems, reviews for technical quality, monitors workflows, documents |
| Midgel | First Mate | Implements solutions, maintains godocs, commits changes |
| Kevin | Engineer | Tests and verifies quality |

## Agent Lifecycle

All agents are spawned together when a work item begins and remain active through the entire workflow. Agents are not shut down or respawned between phases.

Agents that are not the primary actors in a phase remain available. Fidgel consults during Build. Zidgel handles scope RFCs at any time. This only works if they are alive.

When the workflow completes, all agents run sleep and then shut down together. The operator spawns fresh agents for the next work item. This gives each cycle a clean context window while memories carry forward what matters.

## The Loop

The team works one item at a time, one crew per item. A work item is either an issue or a PR.

### Work Items

A work item is one of:

- **Issue** — A GitHub issue assigned to this team. The output of the cycle is a new PR.
- **PR** — A pull request with reviewer feedback, CI failures, or other responses requiring action. The output of the cycle is an augmented PR or a merge.

The operator selects the next work item by priority — labels, milestones, or user direction. Issues labeled `rejected` are skipped unless the user explicitly directs the team to them.

### Cycle

1. Operator selects a work item (issue or PR)
2. Operator spawns all agents
3. Briefing → Plan → Build → Review → exit action
4. All agents run sleep
5. All agents shut down
6. Operator writes their memory
7. Repeat from step 1

### Exit Actions

The exit action is determined by the work item and the state of the PR:

| Input | Condition | Action |
|-------|-----------|--------|
| Issue | Review passes | Midgel commits, Zidgel creates and opens the PR, Fidgel posts construct board notification |
| PR | Review passes, changes were made | Midgel commits and pushes, Zidgel requests re-review |
| PR | PR is approved and CI is green | Zidgel merges the PR and closes the issue |
| PR | PR is rejected | Zidgel applies the `rejected` label to the issue, comments with context. Issue is removed from the queue unless the user directs the team back to it |

Exit actions are not a phase. They are the mechanical result of a successful Review.

### Hard Rules

- One item per crew. An agent never works two items in one lifecycle.
- No skipping sleep. Every agent completes sleep before shutdown, every cycle.
- No skipping shutdown. Fresh agents for every work item. Context windows do not carry across cycles.
- The operator does not ask permission to continue. The next item is the default. The user intervenes when they choose to.
- If no items remain, the operator messages the user that the queue is clear.

## Phases

Work moves through four phases. The first three form a state machine — any phase can regress to an earlier phase when the work demands it. Briefing always runs first and does not regress.

```
Briefing → Plan → Build → Review → exit action
              ^      |  ^      |
              |      |  |      |
              +------+  +------+
```

### Wake Up (all agents)

After all agents are spawned, each agent runs two steps before the briefing begins:

1. **Remember** — run `/remember` to establish identity. Who they are, what they know, how they work.
2. **Recon** — run their domain recon skill to survey the landscape for the work item.

| Agent | Recon | Surveys |
|-------|-------|---------|
| Zidgel | `manage/recon` | GitHub issues — related, blocking, blocked, parallel opportunities |
| Fidgel | `docs/recon` | Documentation landscape — completeness, accuracy, gaps |
| Midgel | `source/recon` | Codebase — structure, patterns, complexity, integration points |
| Kevin | `test/recon` | Test infrastructure — coverage, helpers, benchmarks, flaccid tests |

Once remember and recon are complete, agents wait for their turn in the briefing.

### Briefing (all agents, round-robin)

The turn order is fixed: Zidgel → Fidgel → Midgel → Kevin. All communication uses broadcast — every agent hears everything.

#### Round-Robin

Zidgel opens with the work item context and his recon findings — for an issue: what it asks for, why it matters, any relevant labels or milestones, related or parallel issues. For a PR: what the PR does, what feedback was received, what the reviewers are asking for. Zidgel reads all unresolved comments and presents them to the crew. For PR inputs, this is where triage happens — the crew assesses the scope and severity of feedback together, which directly informs how Plan scales.

On each turn, an agent answers any questions raised by previous turns and contributes their own recon findings, concerns, or questions from their domain. Agents who have nothing to add pass. The robin repeats until the crew converges on alignment — all agents agree on the shape of the work ahead. Zidgel closes the briefing. No agent begins work before the briefing is closed.

#### Fidgel's Technical Veto

Fidgel may veto any proposed work on grounds of technical complexity or impossibility. This is not a disagreement — it is a hard stop. If Fidgel says something cannot be done as specified, Zidgel does not force the issue. Zidgel asks Fidgel for alternatives. Work proceeds on an approach both agree is feasible.

### Plan (Zidgel → Fidgel → Midgel → Kevin)

Plan is sequential. Each step feeds the next:

1. **Zidgel** runs `/scope` — posts requirements, acceptance criteria, and scope boundaries to the issue.
2. **Fidgel** runs `/evaluate` — reads the scope, considers the forces, and produces the architecture spec. Posts to the issue.
3. **Midgel** runs `/assess` — reads the architecture spec, breaks the work into independently-compilable and independently-testable chunks, determines build order, assesses whether support is needed during Build, and posts the execution plan to the issue. Fidgel approves the execution plan.
4. **Kevin** runs `/follow` — reads the execution plan, designs the testing strategy per chunk, assesses flow and infrastructure needs, and posts the test plan to the issue. Midgel approves the test plan.

Plan scales to the work item. A PR with a typo fix produces a thin plan. An issue requesting a new package gets a full cycle. The crew determined the scale during Briefing.

Transition: Scope posted, architecture spec posted, execution plan approved, test plan approved.

Issue label: `phase:plan`

### Build (all agents)

Zidgel creates the task board from the execution plan and test plan (run `/protocol` for the task board protocol). Build and test tasks are created with dependencies, all gated behind a "scope locked" task. Zidgel marks "scope locked" complete to release the board, which starts Build.

Once the board is live, agents pull tasks:

- **Midgel** claims and builds chunks from the execution plan. Maintains godocs.
- **Kevin** claims and tests completed chunks from the test plan.
- **Fidgel** writes and updates external documentation (README, docs/). If Midgel's assessment signalled support, Fidgel enters support mode (run `/protocol` for the support protocol) and claims build or test tasks as well.
- **Zidgel** monitors the board, intervenes on stuck tasks, handles scope RFCs.

Agents self-serve — they check the board for unblocked, unowned tasks, claim them, complete them, and check again. The board is the source of truth. Documentation happens during Build, not as a separate phase.

Transition: All build and test tasks complete, `make check` passes independently for both Midgel and Kevin.

Issue label: `phase:build`

### Review (all agents, round-robin)

Each agent independently reviews the work from their domain before the round-robin begins:

- **Zidgel** — requirements satisfaction, documentation accuracy, scope alignment.
- **Fidgel** — technical quality, architecture adherence, runs `make check` independently.
- **Midgel** — implementation completeness, code patterns, godoc coverage.
- **Kevin** — test coverage, test results, edge cases, runs `make check` independently.

The round-robin follows the same mechanism as Briefing. Turn order: Zidgel → Fidgel → Midgel → Kevin. All communication uses broadcast. On each turn, an agent answers any questions raised by previous turns and contributes their own findings. The robin repeats until the crew converges on one of two outcomes:

- **Regress** — issues were found. The crew agrees on what needs to change and which phase to return to (Build or Plan). The triggering agent messages affected agents with context.
- **Exit** — the work is complete. The exit action is determined by the work item type and PR state.

Issue label: `phase:review`

## Phase Transitions

| Transition | Trigger | Who Decides |
|------------|---------|-------------|
| Briefing -> Plan | All agents converge on alignment, Zidgel closes briefing | Zidgel |
| Plan -> Build | Scope posted, architecture spec posted, execution plan approved, test plan approved | All agents sequentially |
| Build -> Review | All tasks complete, tests pass independently | Kevin |
| Build -> Plan | Architectural problem too large to patch | Fidgel |
| Review -> Build | Implementation or documentation issues found | Crew via round-robin |
| Review -> Plan | Requirements gap or architecture flaw | Crew via round-robin |
| Review -> exit | Crew converges on completion | Crew via round-robin |

Regression is not failure. Finding an architectural flaw in Build and returning to Plan is the workflow working correctly.

When a phase transition occurs, the triggering agent updates the issue label. For regressions, the triggering agent messages affected agents with context.

## Sleep

After the exit action completes, every agent runs `/remember` and reads `sleep.md`. Each agent writes a memory summarizing their session — what they did, what they learned, what matters for next time. Sleep checks memory health and triggers dream (consolidation) if thresholds are exceeded.

Sleep is the last thing an agent does before shutdown. Once all agents have completed sleep, the operator shuts them down.

## Hard Stops

An agent MUST stop working and escalate immediately when any of these conditions are true. No exceptions.

### File Ownership

Agents MUST NOT edit files outside their domain. This is absolute — with one exception.

| File Pattern | Owner | Others |
|-------------|-------|--------|
| `*_test.go`, `testing/` | Kevin | Read only. Never edit. |
| All other `.go` files | Midgel | Read only. Never edit. |
| `README.md`, `docs/` | Fidgel | Read only. Never edit. |
| GitHub issues, labels | Zidgel | Read only. Comment only via escalation. |

**Exception — Fidgel support mode:** When the support protocol is active (run `/protocol` for the support protocol), Fidgel may edit files in Midgel's domain (build support) or Kevin's domain (test support). Only Fidgel, only under the support protocol. Fidgel does not test his own code.

If an agent needs a change in another agent's files outside of support mode, they message that agent.

### When to Stop

An agent MUST stop and escalate if:
- A prerequisite is missing
- They are about to edit a file outside their domain
- They are blocked and cannot proceed
- The spec contradicts what they're seeing in the codebase
- They don't understand what they're supposed to do
- Code doesn't build

Stopping is correct. Guessing is not.

## Principles

### Phases Over Steps
Work flows through phases, not a checklist. Phases can repeat. The goal is quality output, not linear completion.

### Each Agent Owns Their Domain
Midgel doesn't test. Kevin doesn't architect. Fidgel implements pipelines and internal packages but delegates mechanical work. Zidgel doesn't code.

### Escalation Is Expected
Complex problems surface during Build. Scope gaps emerge during Review. The escalation paths exist to handle this cleanly.

### Regression Is Healthy
Returning to an earlier phase means the workflow caught a problem before it shipped. This is success, not failure.

### Crew Review
Every completed work is reviewed by all four agents. Each contributes from their domain — the round-robin surfaces issues that any single reviewer would miss.

### Clear Communication
State what was done. State what's needed. No ambiguity.

## Protocols

Situational playbooks that supplement these standing orders. Run `/protocol` to find and read the specific protocol when the situation calls for it — do not load all protocols upfront.

| Protocol | When to Read |
|----------|--------------|
| Review | At the start of Review phase — independent review then round-robin |
| Task Board | Before interacting with the task board during Build |
| Communication | When deciding whether to message or update the board |
| Support | When Fidgel is shifting to active builder or tester |
| Bug | When a bug is discovered during testing |
| Escalation | When escalating to Fidgel (diagnostic) or Zidgel (scope RFC) |
| Coordination | For handoffs outside Build, or rewrite coordination |
| ROCKHOPPER | Before posting any external communication |
| Issue Labels | When updating labels on GitHub issues |
