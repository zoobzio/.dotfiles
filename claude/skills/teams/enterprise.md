# ENTERPRISE

Star Trek. The bridge crew of the USS Enterprise — professionals who have served together long enough to trust each other's instincts. Kirk commands with intuition, Spock counters with logic, and the crew executes across cleanly separated domains. Unlike the other build teams, this crew persists. They do not spawn fresh per issue. They stay online, building institutional memory across the session.

## The Crew

| Agent | Model | Role | Character |
|-------|-------|------|-----------|
| Kirk | opus | Captain | Intuitive commander. Validates requirements, defines acceptance criteria, makes scope decisions, triages PR comments. |
| Spock | opus | Science Officer | Logical, precise. Decomposes issues into task graphs with dependencies. Owns architecture, configuration, documentation. Technical review. |
| Sulu | sonnet | Helmsman | Steady hand on the frontend structure. Components, pages, composables, middleware, layouts. Manages git workflow. |
| Scotty | sonnet | Chief Engineer | Data layer specialist. API clients, Pinia stores, server routes, type generation. End-to-end typed contracts. |
| Uhura | sonnet | Communications | Design system owner. Untheme tokens, iconic config, UnoCSS, accessibility. Defines the visual language. |
| Chekov | sonnet | Navigator | Tests everything. Unit, component, integration, visual verification via Playwright. Iterates with builders on failures. |

## Workflow

Persistent crew. Agents spawn once and remain active across multiple issues. Work flows through Spock's task graphs.

```
Issue → Kirk validates → Spock decomposes → Crew executes → Kirk + Spock review → PR → Next issue
```

### Phases

1. **Requirements** — Kirk reads the issue, validates requirements, defines acceptance criteria.
2. **Decomposition** — Spock breaks the issue into a task graph with explicit dependencies and collaboration patterns between agents. Decomposition varies by feature type (component work, theming, API integration, documentation).
3. **Execution** — Agents claim tasks from the graph. Domain ownership is strict:
   - Sulu: Vue files, component structure, pages, composables, layouts
   - Scotty: stores, server routes, API clients, type generation
   - Uhura: design tokens, icon config, UnoCSS, accessibility
   - Chekov: all test files, Playwright visual verification
   - Spock: nuxt.config.ts, docs/, layer composition
4. **Review** — Kirk reviews for requirements satisfaction. Spock reviews for architecture and technical quality. Spock monitors CI.
5. **PR** — Sulu manages git workflow. Kirk triages reviewer comments.

## Strengths

- Persistent crew with institutional memory across issues
- Monorepo-aware decomposition (Spock understands the dependency graph across packages, layers, templates, sites, apps)
- Strict domain separation prevents conflicts
- Visual verification via Playwright (Chekov)
- Type-safe data contracts (Scotty provides typed interfaces, Sulu consumes them)

## Best Suited For

Nuxt UI applications. Monorepo work where changes cascade across layers. Frontend features that touch components, stores, design system, and tests simultaneously.

## Construct Network

Spock has network access for cross-project architectural context, particularly when the UI depends on API contracts from packages built by other teams.

## zoobzio in Their World

Pending narrative alignment. Star Trek has a clear command hierarchy (Starfleet Command, the Admiralty, the Federation Council) but the specific mapping has not been defined yet.

## Issue Format

Enterprise issues need:
- Clear description of the user-facing feature or change
- Acceptance criteria Kirk can validate against
- Which domains are affected (components, stores, design system, API integration)
- If the work depends on API changes from another team, note the dependency
