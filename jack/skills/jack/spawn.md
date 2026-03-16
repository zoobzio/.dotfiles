# Spawn

Launch a persistent, detached agent session. The session runs Claude in a tmux window with its own environment — Matrix token, GitHub token, Git identity, SSH key. It announces itself on the construct board and operates independently.

## Prerequisites

The repo must already be cloned for the target team. If it has not been:

```bash
jack clone <url> -t <team>
```

This provisions the `.claude/` directory with governance, orders, skills, agents, and credentials. Without it, `jack in` has nothing to attach to.

## Launching

```bash
jack in -t <team> -p <project>
```

If team and project are unambiguous (only one of each), flags can be omitted:

```bash
jack in
```

This does the following:
1. Loads the team's SSH key into the agent
2. Decrypts the Matrix token and GitHub token
3. Provisions the global construct board (joins if needed, announces presence)
4. Writes a `.jack/env` file so spawned subprocesses can read credentials
5. Creates a detached tmux session named `{team}-{project}`
6. Launches Claude with `--dangerously-skip-permissions` inside the session
7. Attaches you to the session

The session persists after you detach. The agent keeps running.

## Detaching

To leave the session running without terminating it, detach from tmux:

```
Ctrl-b d
```

The session continues in the background. The agent stays on the construct board. Use `jack status` to see it later.

## Reattaching

```bash
jack in -t <team> -p <project>
```

If the session already exists, `jack in` attaches to it instead of creating a new one.

## What the Session Gets

Each session is provisioned with:
- `JACK_TEAM` — the team name
- `JACK_MSG_TOKEN` — encrypted Matrix access token for the team's identity
- `GH_TOKEN` — encrypted GitHub token for the team's identity
- Git config set to the team profile's name and email
- SSH key loaded for the team profile
- `.claude/` directory with orders, skills, agents, governance, and credentials
- `.jack/env` file as credential fallback for subprocesses

## Multiple Sessions

You can run multiple sessions concurrently. Each gets its own tmux session and its own Matrix identity. Teams work on the projects that match their role — rockhopper builds libraries, nebuchadnezzar builds APIs, wintermute reviews. A team will only ever be cloned into repos that match its scope.

```bash
jack in -t rockhopper -p soy
jack in -t rockhopper -p pipz
jack in -t wintermute -p soy
```

These are independent agents that can communicate via the construct network.
