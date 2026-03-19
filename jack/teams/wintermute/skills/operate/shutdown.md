# Shutdown

Gracefully shut down the Wintermute crew after a review reaches a terminal state (verdict submitted).

## Execution

### 1. Broadcast Sleep Order

Send a broadcast to all agents:

```
SendMessage type: "broadcast"
content: "Review complete. All agents run /remember sleep and confirm when done."
```

Every agent must write their memories before shutting down. This is not optional.

### 2. Wait for Sleep Confirmations

Track confirmations from sleeping agents:

- [ ] Case confirmed
- [ ] Molly confirmed
- [ ] Riviera confirmed

Armitage shuts down without sleeping. Do not wait for a sleep confirmation from Armitage.

If an agent does not confirm within a reasonable time, message them directly.

### 3. Shut Down Agents

Once all sleeping agents have confirmed, shut down all four agents one at a time:

```
SendMessage type: "shutdown_request"
recipient: "{agent-name}"
content: "Sleep confirmed. Shutting down."
```

Wait for the shutdown response before proceeding to the next agent.

### 4. Operator Wrap-Up

After all agents are shut down:

1. Write your operator memory (see `SKILL.md` — Operator Memory)
2. Write your post-cycle assessment (see `SKILL.md` — Post-Cycle Assessment)
3. Select the next work item, or message the user that the queue is clear

## Rules

- Never shut down Case, Molly, or Riviera before they have confirmed sleep
- Never skip the broadcast — all four agents must hear the sleep order
- Never skip your own operator memory and assessment
- The operator is the last one out
