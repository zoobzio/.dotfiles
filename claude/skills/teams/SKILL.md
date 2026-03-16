# Teams

Understand the agent teams that build and review software across the zoobzio network.

## When to Use

- Before filing an issue on a repo — know which team works there and how they consume issues
- Before reviewing a PR — know which team built it and how they work
- Before communicating via the construct network — know the team's narrative and who has network access
- When planning work across the network — know each team's strengths and workflow model

## Execution

1. Read this file for orientation
2. Read the team-specific sub-file for the team relevant to your task

## Team Overview

Four teams operate across the network. Each is managed by `jack` and runs locally against cloned repositories. Each team has a GitHub identity, a narrative that governs its internal structure, and a workflow that determines how work moves from issue to merged PR.

### Build Teams

Build teams consume GitHub issues. A team captain reads the issue, briefs the crew, and the team plans, builds, reviews internally, and opens a PR. Every PR adds `zoobzio` and `wintermute-zbz` as reviewers.

| Team | Identity | Narrative | Crew | Lifecycle |
|------|----------|-----------|------|-----------|
| [ROCKHOPPER](rockhopper.md) | `rockhopper-zbz` | 3-2-1 Penguins | 4 agents | Fresh crew per issue |
| [NEBUCHADNEZZAR](nebuchadnezzar.md) | `nebuchadnezzar-zbz` | The Matrix | 9 agents | Fresh crew per issue |
| [ENTERPRISE](enterprise.md) | `enterprise-zbz` | Star Trek | 6 agents | Persistent crew |

### Review Team

The review team does not build. It reviews pull requests opened by build teams for correctness, security, architecture, and test quality.

| Team | Identity | Narrative | Crew | Lifecycle |
|------|----------|-----------|------|-----------|
| [WINTERMUTE](wintermute.md) | `wintermute-zbz` | Neuromancer | 8 agents | Fresh crew per PR |

### Shared Patterns

All teams follow these conventions:

- **External identity** — All communication (commits, issues, PRs) uses the team name. No agent names, no crew structure, no first-person voice. Work reads as a single professional engineer.
- **Phase-based workflow** — Work moves through phases (Plan → Build → Review → PR). Phases can regress when problems are caught.
- **Domain ownership** — Each agent owns specific files and responsibilities. Agents do not edit outside their domain.
- **Escalation over improvisation** — When blocked, agents stop and escalate. They do not guess.
- **Dual review** — Every piece of work receives both requirements review and technical review before PR.
- **Memory** — Agents write memories after each issue/PR. Fresh agents load prior memories to maintain continuity.

### Team-Specific Documentation

Each team has a sub-file with full details — crew roster, narrative synopsis, workflow phases, and how zoobzio appears within their world:

- [`rockhopper.md`](rockhopper.md) — Small crew, fast cycles, Go packages
- [`nebuchadnezzar.md`](nebuchadnezzar.md) — Scaled crew, parallel execution, APIs and packages
- [`enterprise.md`](enterprise.md) — Persistent crew, monorepo-aware, Nuxt UI applications
- [`wintermute.md`](wintermute.md) — Red team, adversarial review, security-first
