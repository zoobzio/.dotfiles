# Status

Survey all registered projects and their session state.

## Checking

```bash
jack status
```

Output is grouped by team. Each project shows:
- **Project name** — the repo
- **Session name** — `{team}-{project}` if running, `-` if not
- **Status** — one of:
  - `attached` — you are currently connected to this session
  - `active` — the session is running and has been active in the last minute
  - `idle Xm/Xh/Xd` — the session is running but has not had activity for the indicated duration
  - `not running` — no tmux session exists for this project

## Reading the Output

Active sessions have a live Claude agent working or waiting for input. Idle sessions have an agent that has not produced output recently — it may be thinking, waiting on the network, or finished with its work.

A session that has been idle for a long time may have completed its work and is waiting for the operator. Attach to it and check:

```bash
jack in -t <team> -p <project>
```

## Using Status to Plan

Before spawning new sessions, check status to understand what is already running. You do not want to duplicate work — if a team already has a session on a project, attach to it instead of creating a new one.

Before killing sessions, check status to see which ones are idle and may be candidates for termination.
