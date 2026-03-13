# Projects

Project-specific context for jack-managed repositories. Each subdirectory maps to a repository name and contains files that jack copies into `.claude/` when a team clones or runs against that repo.

## Discovery

Projects are discovered by directory name — no configuration required. When `jack clone` processes a repository named `sentinel`, it looks for `projects/sentinel/`. The directory must exist and contain at minimum a `MISSION.md`.

## Template

Every project directory must contain a `MISSION.md` following this structure:

```markdown
# Mission: {package-name}

One-line description.

## Purpose

What this package does and why it exists. 2-3 sentences.

## What This Package Contains

Bullet list of what the package provides. Capabilities, not implementation details.

## What This Package Does NOT Contain

Explicit exclusions. What someone might expect to find here but won't.

## Success Criteria

A developer can:
1. [Concrete, verifiable outcome]
2. [Concrete, verifiable outcome]
...

## Non-Goals

Bullet list of things this package intentionally does not do.
```

### Optional Sections

Add these when they apply:

- **Ecosystem Position** — How this package relates to other zoobzio packages
- **Design Constraints** — Hard constraints that shape the implementation
- **The Stack** — For applications: which zoobzio packages are used and why
- **Domain Model** — For applications: entities, relationships, data shape
- **API Surfaces** — For applications with multiple entry points
- **Conventions** — Naming, file layout, registration patterns
- **Roadmap** — Phased delivery plan

## CRITERIA.md

Projects may include a `CRITERIA.md` for the review team. Only Armitage reads this file — it is not shared with other agents. It defines what the review team should care about for this specific repo.

```markdown
# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- [Concrete, verifiable requirement]
- [Concrete, verifiable requirement]

### What This Repo MUST NOT Contain

- [Explicit exclusion — things that would be a defect if present]
- [Explicit exclusion]

## Review Priorities

Ordered by importance. When findings conflict, higher-priority items take precedence.

1. [Highest priority concern]
2. [Next priority]
3. [Next priority]

## Severity Calibration

Guidance for how Armitage classifies finding severity for this specific repo.

| Condition | Severity |
|-----------|----------|
| [Specific condition] | Critical |
| [Specific condition] | High |
| [Specific condition] | Medium |
| [Specific condition] | Low |

## Standing Concerns

Persistent issues or areas of known weakness that should always be checked.

- [Known concern that applies to every review]
- [Known concern]

## Out of Scope

Things the red team should NOT flag for this repo, even if they look wrong.

- [Intentional oddity with explanation]
- [Intentional oddity with explanation]
```

## Additional Files

All files in the project directory are copied to `.claude/` during team application.

## Rules

- Keep MISSION.md focused on *what* and *why*, not *how*
- Technical API details belong in skills (e.g., `grok-*` skills), not here
- Update MISSION.md when project scope changes — it is the contract agents review against
- File names are copied as-is into `.claude/` — choose names that make sense in that context
