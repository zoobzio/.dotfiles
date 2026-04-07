# Decompose

Analyse an issue and create a collaborative task graph with dependencies and assigned owners.

## Execution

1. Read the issue requirements and acceptance criteria
2. Analyse the codebase to understand affected areas
3. Design the task graph
4. Present the task graph to Kirk for review
5. Create tasks via TaskCreate after Kirk approves

## Analysis

Before decomposing, understand:

- **What workspaces are affected?** Check the dependency graph — changes to packages cascade to layers, layers cascade to templates, templates cascade to sites.
- **What domains are involved?** Components (Sulu), data layer (Scotty), design system (Uhura), testing (Chekov).
- **What must happen first?** API contracts before components. Tokens before styling. Source code before tests.
- **Where is collaboration needed?** Interface agreements, visual integration review, test iteration.

## Task Graph Design

### Each Task Specifies

- **Subject** — imperative, specific ("Create UserProfile component", not "Work on user profile")
- **Description** — detailed scope including:
  - Which files/patterns to follow
  - What the expected output looks like
  - How to verify completion
- **Owner** — the agent who does the primary work
- **Collaborators** (when needed) — agents with specific roles
- **Dependencies** — which tasks must complete first

### Collaboration Patterns

Use these when tasks require multiple agents:

| Pattern | When | Example |
|---------|------|---------|
| Agree on interface | Two agents must align on a contract | Scotty + Sulu agree on store shape |
| Review integration | One builds, another validates for their domain | Sulu builds, Uhura reviews visual integration |
| Iterate on failures | Tester and builder resolve issues together | Chekov + Scotty iterate on API test failures |
| Cross-reference findings | Two reviewers compare perspectives | Kirk + Spock during final review |

### Standard Task Types

**Build tasks** — assigned to Sulu, Scotty, or Uhura:
- Blocked by: architecture/interface agreement tasks
- Blocking: corresponding test tasks

**Test tasks** — assigned to Chekov:
- Blocked by: build tasks that produce the code to test
- Blocking: review tasks

**Review tasks** — assigned to Kirk and Spock:
- Blocked by: all build and test tasks
- Kirk reviews requirements satisfaction
- Spock reviews technical quality

### Workspace Dependency Awareness

```
packages/untheme, packages/iconic
    ↓
layers/blocks
    ↓
layers/prose, templates/appula
    ↓
templates/blogula, templates/docula
    ↓
sites/blog, sites/docs/sentinel, apps/vicky
```

If a task modifies a lower-level package, create verification tasks for affected consumers.

## Output

A task graph with clear dependencies. Present to Kirk before creating tasks. After Kirk approves, create all tasks via TaskCreate with proper `addBlockedBy` relationships.

## What This Skill Is NOT

This is not a template. Every issue gets a bespoke decomposition. A component feature decomposes differently from a theming change, which decomposes differently from an API integration. Read the problem. Design the graph.
