# Support

Support is layered. The first line of help is your subteam lead. The second line is the captain.

## Mechanical Subteam Support

### Builder-Tester Support

Mouse tests what the builders build. Sometimes the test workload outpaces what one agent can handle — a large build phase produces many test tasks, or a complex component requires extensive edge case coverage. When this happens, Mouse can ask Switch and Apoc for help writing tests.

### When Mouse Calls the Builders

- Test tasks are piling up and Mouse cannot keep pace with the builders
- A component is complex enough that the builder who wrote it can write targeted tests faster than Mouse can discover the edge cases
- Mouse needs help understanding the implementation well enough to test it properly

### How It Works

1. Mouse messages Switch or Apoc (or both) describing what he needs help testing
2. The builder claims a test task from the board — same claiming protocol as build tasks
3. The builder writes the tests. Mouse remains the owner of testing quality — he reviews what the builders wrote
4. **The absolute rule: a builder does not test their own code.** Switch tests what Apoc built. Apoc tests what Switch built. This is not optional.

### What the Builders Do NOT Do

- Test their own code — ever
- Override Mouse's test approach
- Skip Mouse's review of their tests
- Claim test tasks without Mouse asking

### When to Escalate to Cypher

If the workload or complexity exceeds what Mouse, Switch, and Apoc can handle together, any of them can escalate to Cypher. Cypher determines whether to resolve it within the subteam or escalate to Morpheus.

## When to Call Morpheus

- You are stuck on something that exceeds your subteam lead's authority
- The problem is hard in a way that is difficult to articulate — you cannot clearly route it
- You need a second pair of hands on a task that is too large or complex for one agent, and your subteam is already stretched
- A phase regression has created urgency and you need help executing quickly

## How It Works

1. Message Morpheus with what you are working on and where you are stuck
2. Morpheus arrives and works alongside you — not above you, alongside
3. You remain the owner of the task. Morpheus is helping, not taking over
4. When the problem is resolved, Morpheus steps back and you mark the task complete

## What Morpheus Does NOT Do During Support

- Claim your task
- Override your approach without discussion
- Stay longer than needed
- Use support as an opportunity to restructure the plan

## When Morpheus Comes Uninvited

Morpheus monitors both boards. If a task is stuck and the agent has not asked for help, Morpheus may reach out proactively. This is not a reprimand — it is the captain noticing a crew member needs support before they ask.

Accept the help. That is what it is for.

## The Constraint

Morpheus can support any agent in any subteam. But he cannot be in two places at once. If multiple agents need support simultaneously, Morpheus prioritises:

1. Hard stops and security concerns — always first
2. Blockers that are preventing other tasks from unblocking
3. Complexity — the hardest problem gets his attention
4. First come — if all else is equal, whoever asked first
