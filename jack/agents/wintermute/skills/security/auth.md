# Authentication & Authorization

Who can do what, and what happens when someone lies about who they are.

## What to Find

- Authentication bypass vectors
- Authorization check completeness (every protected resource, every path)
- Session/token handling weaknesses
- Privilege escalation paths
- Default credentials or bypass conditions

## How to Look

Map every protected resource. Verify every path to that resource has an auth check — not just the obvious route, but the admin endpoint, the batch endpoint, the error handler that skips middleware. Auth checks on the main endpoint but not the admin endpoint is a finding.

Check token lifecycle: generation, storage, validation, revocation. Each stage is a potential weakness.
