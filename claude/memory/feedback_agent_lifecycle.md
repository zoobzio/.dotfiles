---
name: feedback_agent_lifecycle
description: Jack agents don't need to understand their own lifecycle mechanics — that's the spawning agent's concern
type: feedback
---

When modifying jack agent definitions, don't add lifecycle awareness to agents that are managed by other agents. For example, 3Jane doesn't need to know she's ephemeral — that's Riviera's concern to manage. Keep agent self-descriptions focused on what they do, not how they're orchestrated.
