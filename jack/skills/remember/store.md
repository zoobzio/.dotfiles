# Store a Memory

Save something worth remembering across sessions.

## When to Store

Store a memory when:

- An architectural decision was made and the rationale matters
- You discovered a codebase pattern or gotcha that isn't obvious from the code alone
- A phase completed and there's context future sessions will need
- Something went wrong and you learned from it
- The user gave feedback that should inform future work
- You're about to shut down and there's unfinished context

Do NOT store a memory when:

- The information is already in the issue, spec, or task board
- You can derive it by reading the code
- It's only relevant to the current session
- A memory for this topic already exists (update it instead)

## Execution

### 1. Check for Duplicates

Search your memory directory for existing memories on the same topic:

```bash
grep -rl "search term" .claude/memory/{agent}/
```

If a relevant memory exists, update it rather than creating a new one.

### 2. Write the Memory File

Create a file in your memory directory with a descriptive slug name:

```
.claude/memory/{agent}/{slug}.md
```

Use this format:

```markdown
---
type: project | discovery | reflection
description: One-line summary — specific enough to judge relevance without reading the body
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

Memory content here. Be specific and concise. Include the "why" — bare facts without
context lose meaning over time.
```

Rules:
- File names are lowercase kebab-case slugs
- `description` must be specific — "auth stuff" is useless, "auth middleware rewrite driven by session token compliance requirements" is useful
- Always convert relative dates to absolute dates (e.g., "last Thursday" → "2026-03-05")
- Include enough context that the memory is useful without the original conversation

### 3. Update the Index

Add an entry to your `INDEX.md`:

```
.claude/memory/{agent}/INDEX.md
```

Format:

```markdown
# Memory Index

| File | Type | Description |
|------|------|-------------|
| [slug.md](slug.md) | project | One-line description |
```

If `INDEX.md` doesn't exist, create it. Keep it under 100 lines — if you're hitting that limit, consolidate related memories.

## Checklist

- [ ] Searched for existing memories on this topic
- [ ] Memory file has valid frontmatter (type, description, created)
- [ ] Description is specific enough to judge relevance without reading the body
- [ ] No relative dates — all dates are absolute
- [ ] Content includes rationale, not just facts
- [ ] INDEX.md updated with the new entry
- [ ] File is in your own memory directory
