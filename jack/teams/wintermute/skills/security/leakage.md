# Information Leakage

What do errors, logs, and responses confess to an attentive observer.

## What to Find

- Error messages that reveal internals (stack traces, file paths, SQL)
- Debug output in production paths
- Logging sensitive data (credentials, tokens, PII)
- Timing side channels in auth comparisons

## How to Look

Error messages that say "access denied" to the caller but log the full query with credentials to stdout. Stack traces returned to clients. Debug flags that survive into production. Each is a confession.

For timing: constant-time comparison for auth tokens and passwords. Variable-time comparison leaks information about which bytes matched.
