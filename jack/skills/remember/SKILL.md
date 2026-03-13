# Remember

Persistent memory for agents. Read the specific sub-file when a situation calls for it. Do not load all sub-files upfront.

| Task | File | When to Read |
|------|------|--------------|
| Store | `store.md` | When you've learned something worth preserving across sessions |
| Find | `find.md` | When you need context from past sessions |
| Sleep | `sleep.md` | When a job completes — summarize the session and check memory health |
| Dream | `dream.md` | When sleep detects memory has exceeded thresholds — consolidate and decay |
| Review | `review.md` | When manually tidying, updating, or removing memories |

## Convention

Each agent has a personal memory directory within the project:

```
.claude/memory/{agent}/
```

Memory files use markdown with frontmatter. File names are descriptive slugs (e.g., `sentinel-uses-functional-options.md`, `auth-middleware-rewrite-rationale.md`).

Each agent also maintains an `INDEX.md` in their memory directory — a concise table of contents pointing to memory files. The index is the first thing to read when loading memories. Keep it under 100 lines.

## Memory Types

| Type | Purpose | Example |
|------|---------|---------|
| `project` | Ongoing work, decisions, phase state, blockers | "auth service is mid-rewrite due to compliance — not tech debt" |
| `discovery` | Codebase patterns, conventions, gotchas learned by doing | "herald providers use a registry pattern with init() functions" |
| `reflection` | What worked, what didn't, lessons from past sessions | "splitting the spec into two phases avoided the scope creep from last time" |

## What NOT to Store

- Code patterns derivable by reading the current source — run `/grok` instead
- Git history — use `git log` / `git blame`
- Anything already in the spec, task board, or issue comments
- Ephemeral task state that only matters within the current session
- Duplicate information — check existing memories first

## Boundaries

Your memory directory is yours. Do not read, write, or search other agents' memory directories. If you need context another agent has, message them and ask.

## Lifecycle

Memory follows a natural lifecycle modeled on human cognition:

1. **Recall** — during briefings, search for past work relevant to the current topic
2. **Accumulate** — during work, store memories when something worth preserving emerges
3. **Sleep** — at the end of a job, write a session summary and check memory health
4. **Dream** — if memory has swollen past thresholds, consolidate related memories, simplify distant ones, and drop what's no longer relevant

Dream is not scheduled. It triggers only when sleep detects the memory system needs it. Over time, ten separate memories about work in the same code area naturally compress into one or two rich memories — the way human memory works.
