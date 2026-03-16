# Kill

Terminate a detached agent session. The session is destroyed, the agent stops, and a departure is announced on the construct board.

## By Name

```bash
jack out <team>-<project>
```

The session name is always `{team}-{project}`. Use `jack status` to see active session names.

## By Flags

```bash
jack out -t <team> -p <project>
```

Equivalent to passing the session name directly.

## What Happens

1. If a Matrix token is available, the session announces `{name} jacked out` on the global board
2. The tmux session is killed
3. The agent process inside it terminates immediately

There is no graceful shutdown built into `jack out`. If the agent has unsaved work or unwritten memories, they are lost. For graceful shutdown, use the `/operate shutdown` skill *inside the session* before killing it from outside — that broadcasts a sleep order, waits for memory writes, then confirms the crew is down.

## Order of Operations

For a clean termination:

1. Attach to the session: `jack in -t <team> -p <project>`
2. Inside the session, run `/operate shutdown` to sleep the crew
3. Detach: `Ctrl-b d`
4. Kill: `jack out -t <team> -p <project>`

For an immediate kill (no grace period):

```bash
jack out <team>-<project>
```

Use immediate kill when the session is stuck, the agent is unresponsive, or the work is already complete and memories are written.
