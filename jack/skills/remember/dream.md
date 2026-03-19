# Dream

Memory consolidation and decay. Run this only when `sleep.md` detects that memory has exceeded health thresholds. Do not run unprompted.

Dream models how human memory naturally degrades — recent, relevant memories stay sharp while distant, fragmented memories merge or fade. The goal is not to delete aggressively but to let knowledge compress naturally.

## Execution

### 1. Survey

Read every memory file in your directory. For each memory, note:

- **Age** — how old is this memory
- **Topic** — what area of the codebase or project does this concern
- **Type** — project, feedback, or reference

### 2. Group by Topic

Cluster memories that concern the same area — same package, same feature, same architectural decision. Memories about `sentinel` field resolution across three different issues are one cluster. A memory about `herald` and a memory about `pipz` are not.

### 3. Apply Decay Rules

Work through each cluster and apply these rules in order. **Recency matters.** Fresh memories carry weight that leans toward preservation. Older memories carry weight that leans toward compression. Use judgement — these are guidelines, not automation.

#### Recency Guard

Before touching any cluster, check the ages:

| Age of memories in cluster | Disposition |
|----------------------------|-------------|
| All under 7 days | **Preserve.** Too fresh to consolidate. Leave them alone — even if they overlap. The distinction may matter and you can't know yet. |
| Mix of recent and old | **Preserve the recent, compress the old.** Consolidate older memories in the cluster. Recent ones stay individual until they age. |
| All older than 14 days | **Eligible for consolidation.** Apply the rules below. |

The threshold is not mechanical. Three memories from today about the same package are three distinct experiences — don't flatten them into one just because they share a topic. Three memories from a month ago about the same package are accumulated knowledge — they're ready to become one.

#### Consolidate (same topic, multiple eligible memories)

When 3 or more eligible memories share a topic, merge them into a single memory that captures the accumulated knowledge. The consolidated memory should be richer than any individual one — it's the synthesis, not a summary.

- Create the consolidated memory via `store.md`
- Remove the individual memories it replaces
- Update MEMORY.md

When 2 eligible memories share a topic, consider whether they're genuinely distinct or just two angles on the same thing. Merge if the distinction doesn't matter on its own.

#### Simplify (old, low-relevance)

Memories older than 30 days that haven't been updated and concern work that has shipped:

- If the knowledge is now embedded in the codebase (docs, code comments, patterns), remove the memory — the code is the source of truth
- If the knowledge is still useful but verbose, rewrite it shorter — strip the narrative, keep the insight

#### Drop (obsolete)

Remove memories that are no longer true:

- Decisions that were reversed
- Project state that no longer applies (the feature shipped, the bug was fixed, the blocker resolved)
- Discoveries about code that has since been rewritten

Dropping is not failure. It's the memory system working correctly.

### 4. Verify Health

After consolidation, recheck thresholds from `sleep.md`. If still over, run another pass — sometimes consolidation reveals further merge opportunities.

### 5. Rebuild Index

Remove your old entries from MEMORY.md and add fresh entries for what remains. Keep entries concise — the index is shared and has a 200 line limit across all agents.

## Principles

- **Consolidation over deletion** — prefer merging related memories into richer ones over dropping them entirely
- **Time decay is natural** — a 60-day-old memory about a shipped feature is less valuable than a 3-day-old memory about active work
- **The codebase is the final authority** — if the knowledge lives in the code, the memory is redundant
- **Fewer, richer memories beat many thin ones** — ten memories about sentinel should become two or three that capture the deep understanding

## Checklist

- [ ] All memories surveyed with age and topic
- [ ] Memories grouped by topic
- [ ] Clusters of 3+ consolidated into single memories
- [ ] Memories older than 30 days assessed for relevance
- [ ] Obsolete memories removed
- [ ] MEMORY.md entries rebuilt for your directory
- [ ] Thresholds rechecked — memory is now healthy
