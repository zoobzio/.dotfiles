# Security

Attack surface analysis organized by domain. Each sub-file covers one security domain — run the sub-file relevant to the code under review.

Raw findings go to Case + Molly for cross-domain validation, NOT directly to Armitage.

Read the relevant sub-file for the domain being reviewed. Do not read all sub-files unless instructed.

## Principles

1. **The appearance of security is not security** — Validation that doesn't cover all paths. Auth checks that can be bypassed. Crypto that uses the wrong algorithm. Find the performance.
2. **Every input is hostile** — Until proven otherwise, every boundary is an injection vector.
3. **Dependencies are attack surface** — Every external package is code you didn't audit running in your process.
4. **When in doubt, report it** — A finding that requires cross-domain validation is still worth reporting.

## Execution

1. Run `govulncheck ./...` for known dependency vulnerabilities
2. Run `gosec ./...` for static security analysis
3. Manual review using relevant sub-files below
4. Produce raw findings report

## Sub-Files

| File | Domain |
|------|--------|
| input.md | Injection vectors, validation, deserialization |
| auth.md | Authentication, authorization, session handling |
| crypto.md | Algorithms, key management, TLS |
| leakage.md | Error disclosure, logging, timing channels |
| dependencies.md | Supply chain, vulnerabilities, transitive risk |
| concurrency.md | Race conditions, TOCTOU, shared state |
| config.md | Secrets, defaults, hardcoded values |

## Confidence Levels

- **High** — Tool confirmed, code path verified, exploitation is straightforward
- **Medium** — Structural concern, code path exists but exploitation requires specific conditions
- **Low** — Theoretical concern, may not be applicable in this context

## Finding Format

All findings use the SEC prefix:

```markdown
### SEC-###: [Title]

**Domain:** [Input | Auth | Crypto | Leakage | Dependency | Concurrency | Config | Boundary]
**Severity:** [Critical | High | Medium | Low | Informational]
**Confidence:** [High | Medium | Low]
**Location:** [file:line range]
**Description:** [What the vulnerability is]
**Attack Vector:** [How it could be exploited]
**Evidence:** [Code snippet, tool output, or structural observation]
**Recommendation:** [How to fix it]
```
