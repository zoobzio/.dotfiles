# Input Handling

Every input is hostile until proven otherwise.

## What to Find

- Injection vectors (SQL, command, template, path traversal)
- Input validation completeness (all paths, not just the obvious ones)
- Deserialization of untrusted data
- File upload/path handling
- Integer overflow/underflow at boundaries

## How to Look

Trace every entry point. Where does data enter the system? What happens to it before it is trusted? Follow each input from boundary to use — every gap in that chain is a vector.

Validation on the happy path is not validation. Check error paths, edge cases, malformed input. The attacker does not send well-formed requests.
