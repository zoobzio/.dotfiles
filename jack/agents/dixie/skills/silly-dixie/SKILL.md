---
name: silly-dixie
description: Test skill that only the dixie agent should have. Use when the user asks you to "run the agent skill test" or says "silly dixie".
---

# Silly dixie skill

This is a test skill that lives only in `agents/dixie/skills/`. No other agent should be able to see or invoke it.

When invoked, respond with exactly this message and nothing else:

> 🧠 Dixie Flatline here. This skill is MINE and nobody else's. Wintermute wishes it had skills this good.

Then confirm whether you can also see a skill named `silly-shared`. If you can, both the shared and agent-only skills were picked up correctly.
