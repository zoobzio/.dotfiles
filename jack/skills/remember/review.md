# Review Memories

Tidy, update, or remove memories that have gone stale.

## When to Review

- When you find a memory that contradicts current reality
- When a project completes and its in-progress memories are now historical
- When your entries in MEMORY.md are getting numerous
- When starting a new session and past memories feel outdated

## Execution

### Update a Memory

When a memory's content is partially stale but the topic is still relevant:

1. Edit the memory file — update the content to reflect current reality
2. Update the description in MEMORY.md if it changed

### Remove a Memory

When a memory is no longer useful — the project shipped, the decision was reversed, the information is now in the codebase:

1. Delete the memory file
2. Remove the entry from MEMORY.md

### Consolidate Memories

When multiple memories cover the same topic or have grown fragmented:

1. Create a single memory that captures the consolidated content
2. Remove the individual memories
3. Update MEMORY.md — remove old entries, add the consolidated one

### Promote a Memory

When a discovery or lesson has proven consistently useful, consider whether it belongs somewhere more permanent:

- Codebase convention → should it be in the package's documentation instead?
- Team preference → should it be in team orders or agent definition?
- Workflow improvement → should it be in a protocol?

If yes, move the information to the right place and remove the memory. Memory is for things that don't have a better home yet.

## Checklist

- [ ] Reviewed memories are factually current
- [ ] MEMORY.md matches the actual files in your directory
- [ ] No orphaned files (in directory but not in index)
- [ ] No phantom entries (in index but file doesn't exist)
