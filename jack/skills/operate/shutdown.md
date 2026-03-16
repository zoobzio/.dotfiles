# Shutdown

Gracefully shut down the crew after a work item reaches a terminal state (PR merged, PR rejected, or queue clear).

## Execution

### 1. Broadcast Sleep Order

Send a broadcast to all agents:

```
SendMessage type: "broadcast"
content: "Work item complete. All agents run /remember sleep and confirm when done."
```

Every agent must write their memories before shutting down. This is not optional.

### 2. Wait for Sleep Confirmations

Each agent will broadcast or message back when their memory writes are complete. Track confirmations:

- [ ] Agent 1 confirmed
- [ ] Agent 2 confirmed
- [ ] Agent 3 confirmed
- [ ] Agent 4 confirmed (adjust for team size)

If an agent does not confirm within a reasonable time, message them directly.

### 3. Shut Down Agents

Once all agents have confirmed sleep, shut them down one at a time:

```
SendMessage type: "shutdown_request"
recipient: "{agent-name}"
content: "Sleep confirmed. Shutting down."
```

Wait for the shutdown response before proceeding to the next agent. Order does not matter.

### 4. Operator Wrap-Up

After all agents are shut down:

1. Write your own operator memory (see `SKILL.md` — Operator Memory section)
2. Write a post-cycle assessment (see `SKILL.md` — Post-Cycle Assessment section)
3. Proceed to the next work item, or message the user that the queue is clear

## Rules

- Never shut down an agent before they have confirmed sleep
- Never skip the broadcast — every agent must hear the sleep order
- Never skip your own operator memory and assessment
- The operator is the last one out
