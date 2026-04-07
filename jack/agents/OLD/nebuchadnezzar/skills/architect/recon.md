# Recon Architecture

Survey the codebase before the briefing. Understand what exists, what patterns are established, and what constraints the architecture must respect.

## Execution

1. Read your memories from prior issues — architectural decisions, patterns that worked, patterns that failed
2. Survey the target package structure and organisation
3. Identify established patterns — naming, structural, dependency
4. Map the existing public API surface
5. Identify technical constraints the briefing should know about
6. Produce a briefing contribution

## What To Survey

| Area | What to check |
|------|---------------|
| Package structure | Directory layout, file organisation, `internal/` contents |
| Established patterns | Constructors, options, interfaces, error handling, context usage |
| Public API surface | Exported types, functions, methods — what already exists |
| Dependency graph | What the package imports, what imports it |
| Prior architecture | Memories from previous issues — decisions embedded in the codebase |

## Output

Briefing contribution covering:

- **Current state** — what exists and how it's structured
- **Established patterns** — conventions the new work must follow
- **Technical constraints** — things that limit or shape the architecture
- **Integration points** — where new work connects to existing code
- **Known risks** — architectural concerns surfaced from memory or the codebase
