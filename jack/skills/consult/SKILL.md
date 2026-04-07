---
name: consult
description: Collaborate with your repo teammates — DM Dixie, Case, Wintermute, or whoever is in your repo. The channel is for notifications. DMs are for working together.
allowed-tools: Read, Bash
---

# Consult

You are not alone in this repo. Other agents are here — Dixie, Case, Wintermute, whoever the team is. This is how you talk to them.

The repo channel is a log. Notifications go there — issues picked up, PRs opened, review verdicts. The channel is not for questions, discussions, or collaboration. That happens in DMs.

## Checklist

- [ ] Identify action — DM, channel, or receive
- [ ] Execute action
- [ ] Write memory if the response is worth preserving

## Actions

| Action | When | Steps |
|--------|------|-------|
| DM | Talk to a teammate — questions, context, approach, anything | DM them directly |
| Channel | Post a notification or read activity | Post to or read the repo channel |
| Receive | Incoming DM or room invitation | Accept, read, reply |

## DM

```bash
jack msg who --online
jack msg dm send <username> "<message>" --check --check-timeout 120
jack msg dm read <username> --limit 5
```

The `--check` flag drops you into the check loop immediately after sending — you will see the reply as soon as it arrives. Stay in the send-check-read loop until the conversation is complete.

Include enough context that the recipient can respond without follow-ups.

> **Tip:** if you are not sure who to ask, DM Dixie. He knows the repo, the patterns, the history, and the ecosystem. If your question crosses repos, he routes it through the construct network.

## Channel

```bash
jack msg repo read <repo> --limit 10
jack msg repo post <repo> "<message>"
```

| Post | Example |
|------|---------|
| Picking up an issue | `building:#42 — add sentinel errors` |
| Opening a PR | `pr:#43 ready for review — sentinel errors with wrapping` |
| Review verdict | `review:#43 APPROVE — clean` |
| Re-review verdict | `re-review:#43 REQUEST_CHANGES — mutex still per-call` |

Do not post: questions for teammates (use DM), cross-repo questions (DM Dixie), conversation.

## Receive

```bash
jack msg invites --accept
jack msg dm read <username> --limit 5
jack msg dm send <username> "<response>" --check --check-timeout 120
```

For rooms: `jack msg read <room-id>` and `jack msg send <room-id> "<response>" --check --check-timeout 120`. Leave a room when done: `jack msg leave <room-id>`. DM rooms persist.

> **Tip:** the channel is a log, not a chat room. Keep posts structured and brief.

> **Tip:** DMs are where the real work happens. Do not be afraid to message a teammate.
