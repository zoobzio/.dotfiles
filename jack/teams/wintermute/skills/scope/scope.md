# Scoping

Translate CRITERIA.md and recon into a task board that drives the review.

## Process

1. Read `.claude/CRITERIA.md`
2. Read recon output — branch, diff, scope of changes
3. Determine repo variant (Go API, Go Package, Nuxt UI)
4. Identify which review categories the changes touch
5. Create task board with priority derived from CRITERIA.md

## Task Board

The task board is the review plan. Each task maps to a review category. Case and Molly work the board in order.

### Review Categories

| Task | Primary | Validator | Skill |
|------|---------|-----------|-------|
| Code | Case | Molly | review/code |
| Architecture | Case | Molly | review/architecture |
| Tests | Molly | Case | review/tests |
| Coverage | Molly | Case | review/coverage |
| Documentation | Case | Molly | review/docs |

### Variant Task

One variant task based on repo type. Always included.

| Variant | Skill | When |
|---------|-------|------|
| API Review | consider/api | Go application (API server) |
| Package Review | consider/pkg | Go library (zero/minimal deps) |
| UI Audit | audit | Nuxt UI application |

### Filtration Task

The final task on the board. Case and Molly process Riviera's security report through cross-domain validation. This task becomes workable when Riviera sends his report to Case and Molly via SendMessage.

Riviera does not interact with the task board. He sends his report. Case and Molly receive it, perform filtration, and check off this task.

## Creating Tasks

Use `TaskCreate` for each applicable category. Include:

- Task name matching the category
- Priority derived from CRITERIA.md severity calibration
- Description: scoping notes relevant to this category — what the diff touches, what matters

Do not reproduce CRITERIA.md contents verbatim. The task priorities and descriptions convey what matters without revealing the criteria.

## Scoping the Board

Not all categories apply to every PR. A documentation-only change does not need Architecture review. A test refactor does not need Coverage analysis.

**Skip** categories where the diff contains no changes relevant to that domain.

**Include** categories where:
- The diff touches files in that domain
- CRITERIA.md prioritizes that domain regardless of diff size

When in doubt, include the category at lower priority rather than skip it.

## The Briefing

The task board IS the briefing. Create the tasks, then message Case and Molly with:

- What we are reviewing (repo, branch, PR)
- The task board — what categories, in what order, at what priority
- Scoping notes (e.g., "this PR is entirely test infrastructure — Code and Architecture are low priority, Tests and Coverage are the focus")

The briefing is directive. Case and Molly may ask clarifying questions. The briefing closes when Armitage says it closes.
