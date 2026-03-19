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

Agent memories live in the project's memory directory, scoped by agent name:

```
~/.claude/projects/<project>/memory/{agent}/
```

The shared `MEMORY.md` index in the memory root is auto-loaded at the start of every session. It points to all memory files across all agents. Each agent maintains entries in this shared index for their own memories.

Memory files use markdown with frontmatter. File names are descriptive slugs (e.g., `sentinel-uses-functional-options.md`, `auth-middleware-rewrite-rationale.md`).

## Memory Types

Use the types supported by the memory system:

| Type | Purpose | Example |
|------|---------|---------|
| `project` | Ongoing work, decisions, phase state, blockers | "auth service is mid-rewrite due to compliance — not tech debt" |
| `feedback` | Corrections, guidance, lessons from past sessions | "splitting the spec into two phases avoided the scope creep from last time" |
| `reference` | Pointers to external resources and their purpose | "pipeline bugs tracked in Linear project INGEST" |

## What NOT to Store

- Code patterns derivable by reading the current source — run `/grok` instead
- Git history — use `git log` / `git blame`
- Anything already in the spec, task board, or issue comments
- Ephemeral task state that only matters within the current session
- Duplicate information — check existing memories first

## Etiquette

The shared index means you can see what memories other agents have. That visibility is for coordination — so you know context exists, not so you can read through someone else's memories. If you see something relevant in the index, ask the agent about it rather than reading their files directly.

Your memory directory is yours to write. Do not write to another agent's directory.

## Lifecycle

Memory follows a natural lifecycle:

1. **Recall** — during briefings, search for past work relevant to the current topic
2. **Accumulate** — during work, store memories when something worth preserving emerges
3. **Sleep** — at the end of a job, write a session summary and check memory health
4. **Dream** — if memory has swollen past thresholds, consolidate related memories, simplify distant ones, and drop what's no longer relevant

Dream is not scheduled. It triggers only when sleep detects the memory system needs it. Over time, ten separate memories about work in the same code area naturally compress into one or two rich memories — the way human memory works.
