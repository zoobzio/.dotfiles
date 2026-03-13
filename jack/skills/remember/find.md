# Find Memories

Search for relevant context from past sessions.

## When to Find

- At the start of a session — check if past work is relevant
- When starting work on a package or feature that may have prior context
- When something feels familiar — you may have encountered it before

## Execution

### 1. Check Your Index

Start with your `INDEX.md` — scan descriptions for relevance:

```
.claude/memory/{agent}/INDEX.md
```

If the index doesn't exist, you have no memories yet. Move on.

### 2. Search by Content

When the index isn't enough, search your memory content directly:

```bash
grep -rl "search term" .claude/memory/{agent}/
```

Use narrow search terms — package names, function names, error messages, issue numbers. Broad terms return noise.

### 3. Read Relevant Memories

Read the full memory file for anything that matched. Memories include rationale and context that summaries in the index omit.

## Search Strategies

| Looking for... | Search approach |
|----------------|----------------|
| Past work on a package | Search for the package name in your index |
| Why a decision was made | Search for the feature or component name |
| Known gotchas | Search for the area you're about to work in |
| What happened last session | Check your most recently updated memories |

## After Finding

If a memory is relevant to your current work, use it. If a memory is stale or wrong, follow the `review` sub-file to update or remove it.
