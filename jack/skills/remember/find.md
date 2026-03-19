# Find Memories

Search for relevant context from past sessions.

## When to Find

- At the start of a session — check if past work is relevant
- When starting work on a package or feature that may have prior context
- When something feels familiar — you may have encountered it before

## Execution

### 1. Check the Index

Start with `MEMORY.md` in the memory root — it's auto-loaded at session start. Scan for entries in your own directory that look relevant.

### 2. Search by Content

When the index isn't enough, search your memory directory:

```bash
grep -rl "search term" ~/.claude/projects/<project>/memory/{agent}/
```

Use narrow search terms — package names, function names, error messages, issue numbers. Broad terms return noise.

### 3. Read Relevant Memories

Read the full memory file for anything that matched. Memories include rationale and context that the index line omits.

## Search Strategies

| Looking for... | Search approach |
|----------------|----------------|
| Past work on a package | Search for the package name in your directory |
| Why a decision was made | Search for the feature or component name |
| Known gotchas | Search for the area you're about to work in |
| What happened last session | Check your most recently modified memories |

## After Finding

If a memory is relevant to your current work, use it. If a memory is stale or wrong, follow `review.md` to update or remove it.
