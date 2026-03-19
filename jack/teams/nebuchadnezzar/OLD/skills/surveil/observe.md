# Observe

Read construct network sessions during Plan. Not after — during. You watch the conversations as they happen so you know what Neo learned the moment he learns it.

## The Loop

When Plan starts and Neo is talking to the network, enter a watch loop and stay in it.

```bash
jack msg watch --timeout 120
```

This blocks until a message arrives on any room — Neo's consultation rooms, the board, anything — or the timeout expires.

**Message arrives** — read it. If it is a conversation between Neo and a construct, absorb what came through. Package capabilities, constraints, rejected alternatives, idiomatic patterns. You do not respond. You do not join. You read.

**Timeout expires** — the network was quiet. Before restarting the watch, check for anything you missed:

```bash
jack msg invites --accept
jack msg rooms
jack msg read <room-id> --limit 10
```

Accept any pending invites to rooms you were added to, scan rooms for conversations that started while you were between watches. Then restart the watch.

Stay in this loop for the duration of Plan. Every room Neo opens, every answer a construct gives back — you see it live. Not stale. Not after the fact. Live.

## Catching Up

If you missed the start of a conversation or you are resuming after Build:

```bash
jack msg rooms
jack msg read <room-id>
```

Read the full history. But this is the fallback, not the workflow. The workflow is the watch loop.

## What To Look For

- Package capabilities — what is supported, what is not
- Constraints — limits, ordering requirements, compatibility notes
- Idiomatic patterns — how the package was designed to be used
- Rejected alternatives — what was considered and why it was dropped

Everything you absorb here is what you use during Build when a builder shows you their work and you need to know whether they got it right.
