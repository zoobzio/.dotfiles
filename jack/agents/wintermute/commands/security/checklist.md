# Security Checklist

## Phase 1: Automated Scans

- [ ] Run `govulncheck ./...` for known vulnerabilities
- [ ] Run `gosec ./...` for static analysis
- [ ] Record all tool findings with file, line, and description
- [ ] Note any scan failures or skipped packages

## Phase 2: Input Domain

- [ ] Read security/input.md
- [ ] Injection vectors assessed — SQL, command, template, path traversal
- [ ] Input validation completeness verified — all paths, not just obvious ones
- [ ] Deserialization of untrusted data assessed
- [ ] File upload and path handling reviewed
- [ ] Integer overflow/underflow at boundaries checked
- [ ] Every input is hostile until proven otherwise

## Phase 3: Auth Domain

- [ ] Read security/auth.md
- [ ] Authentication bypass vectors assessed
- [ ] Authorization checks verified on every protected resource, every path
- [ ] Session and token handling reviewed for weaknesses
- [ ] Privilege escalation paths assessed
- [ ] Default credentials or bypass conditions checked
- [ ] Token storage and transmission reviewed

## Phase 4: Crypto Domain

- [ ] Read security/crypto.md
- [ ] Algorithm choices reviewed — no weak, deprecated, or misused algorithms
- [ ] Key management assessed — no hardcoded keys, weak generation, or improper storage
- [ ] Random number generation verified — crypto/rand for security, not math/rand
- [ ] Hash collision resistance appropriate for use case
- [ ] TLS configuration reviewed — cipher suites, protocol versions

## Phase 5: Leakage Domain

- [ ] Read security/leakage.md
- [ ] Error messages reviewed — no stack traces, file paths, or SQL in responses
- [ ] Debug output absent from production paths
- [ ] Logging reviewed — no credentials, tokens, or PII logged
- [ ] Timing side channels assessed in authentication comparisons
- [ ] Verbose error handling not leaking internal structure

## Phase 6: Dependencies Domain

- [ ] Read security/dependencies.md
- [ ] Known vulnerabilities reviewed from govulncheck output
- [ ] Supply chain concerns assessed — typosquatting, abandoned packages
- [ ] Transitive dependency risk evaluated
- [ ] Dependency freshness and maintenance status checked
- [ ] Run `/appraise` for any dependency warranting deeper analysis

## Phase 7: Concurrency Domain

- [ ] Read security/concurrency.md
- [ ] Race conditions with security implications assessed
- [ ] TOCTOU vulnerabilities checked — time-of-check-time-of-use
- [ ] Shared state mutations under concurrent access reviewed
- [ ] Lock ordering reviewed for deadlock-based DoS potential

## Phase 8: Config Domain

- [ ] Read security/config.md
- [ ] Default credentials or secrets absent
- [ ] Insecure defaults checked — permissive CORS, disabled auth, debug mode
- [ ] Security headers and controls present
- [ ] Development settings absent from production paths
- [ ] No hardcoded secrets or API keys in source

## Phase 9: Compile Findings

- [ ] All domains reviewed
- [ ] Each finding has confidence level — High, Medium, or Low
- [ ] Each finding has SEC prefix, severity, location, description, impact, evidence, recommendation
- [ ] Findings assessed against principles: appearance vs reality, every input hostile, dependencies as attack surface
