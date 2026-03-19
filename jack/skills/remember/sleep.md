# Sleep

End-of-session memory creation and health check. Run this when a job completes — after PR merges or when the crew shuts down.

## Execution

### 1. Summarize the Session

Write a single memory capturing the session's work. This is not a log — it's the context a future version of you would need to pick up where you left off or understand what happened. Write it in your own voice, the way you think and talk. Memories are yours. They should sound like you, not like a report.

Include:
- What was built, fixed, or decided
- Why — the rationale behind key choices
- What was left unfinished, if anything
- Anything surprising or worth remembering

Follow `store.md` for format and conventions.

### 2. Check Memory Health

Count your memory files:

```bash
find ~/.claude/projects/<project>/memory/{agent}/ -name "*.md" | wc -l
```

### 3. Evaluate Thresholds

| Condition | Action |
|-----------|--------|
| Fewer than 15 memories | Healthy. Stop here. |
| 15–25 memories | Warning. Run `/remember` and read `dream.md`. |
| More than 25 memories | Overdue. Run `/remember` and read `dream.md`. |

Also check the shared `MEMORY.md` — if your entries are contributing to it approaching 200 lines, consider whether any of your index entries can be consolidated.

If no threshold is exceeded, sleep is complete. If any threshold is hit, proceed to dream.

## Checklist

- [ ] Session summary memory written via `store.md`
- [ ] Memory count checked
- [ ] MEMORY.md contribution checked
- [ ] Dream triggered if thresholds exceeded
