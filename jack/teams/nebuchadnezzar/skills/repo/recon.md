# Recon

Survey the repository state before the briefing. Understand what the crew is building on top of.

## Execution

1. Read your memories from prior issues — CI failures, reviewer patterns, health issues that recurred
2. Check open issues for overlap with the current work
3. Run lint and build checks to assess codebase cleanliness
4. Check dependencies for security advisories
5. Produce a briefing contribution

## What To Survey

| Area | What to check |
|------|---------------|
| Open issues | Anything that overlaps with, relates to, or provides context for the current work |
| CI state | Is the default branch green? Any ongoing failures? |
| Lint | Does `make lint` pass on the current state? |
| Security | Any advisories against current dependencies? (`govulncheck ./...`) |
| Prior PR context | Memories from previous issues — what reviewers flagged, what CI caught |

## Output

Briefing contribution covering:

- **Overlapping issues** — related work, prior attempts, context the crew should have
- **Repo health** — lint state, CI state, anything that is not clean
- **Security concerns** — advisories on dependencies, especially those the current work will touch
- **Reviewer patterns** — things reviewers have consistently flagged that the crew should address proactively
