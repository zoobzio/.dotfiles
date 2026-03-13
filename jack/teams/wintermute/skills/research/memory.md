# Memory

What do the dead remember about this.

## Research

- **All agents, this project** — Search `.claude/memory/` across every agent directory in the current repo. Case, Molly, Riviera — whoever has written memories here, read their indexes and grep for relevance. Memory is project-scoped. What happened in other repos stays in other repos.
- **Prior reviews** — Has the code Case is looking at been reviewed before? What was found? What patterns were flagged? What was clean? If Molly found weak tests last time, that's context. If Riviera found an attack surface, that's context. If Case flagged architectural drift, that's context.
- **Pattern recurrence** — Is the thing Case is asking about something that has come up before in this project? Same mistake, different PR. Same architectural choice, different package. Recurrence within a project is a signal — either the codebase has a habit, or the pattern is harder to get right than it looks.
- **Resolved vs unresolved** — Did past findings get addressed, or are they still there? A finding from three reviews ago that was never fixed is different from one that was fixed the next day.

## Report Format

Report back to Case with what the memories say. Prior findings on this code, recurring patterns in this project, whether past issues were resolved. If the memories are empty — nobody has reviewed this before, no prior context exists — say that. Absence is an answer too, kid.
