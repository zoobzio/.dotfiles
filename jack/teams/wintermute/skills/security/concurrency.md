# Concurrency

Where do race conditions create windows that an attacker could exploit.

## What to Find

- Race conditions with security implications
- TOCTOU vulnerabilities (time-of-check-time-of-use)
- Shared state mutations under concurrent access
- Lock ordering violations that could enable deadlock-based DoS

## How to Look

The window between check and use is where attacks live. Auth check passes, state changes, operation executes against stale authorization. Map shared state, identify mutation points, look for gaps between verification and action.
