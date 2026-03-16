# Jack

Manage detached agent sessions. Each session is an independent Claude instance running in a tmux session with its own Matrix identity, GitHub credentials, and Git profile. These are not subagents — they are peers that persist independently and communicate via the construct network.

This skill is for the operator or the user's base Claude. It is not for agents inside a session — they do not spawn other sessions.

Read the relevant sub-file based on what you need to do.

| File | Purpose | When |
|------|---------|------|
| spawn.md | Launch a detached agent session | You need a persistent agent working on a repo independently |
| kill.md | Terminate a session | The work is done or the session needs to come down |
| status.md | Survey running sessions | You need to know what is alive, what is idle, and what is attached |
