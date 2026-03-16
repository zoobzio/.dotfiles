# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Priority resolution order is correct: secret > env > default > zero value
- Required fields with no value produce ErrRequired
- Type conversion handles all documented types correctly
- SecretProvider ErrSecretNotFound falls through to next source
- Nested structs are loaded recursively
- Validator.Validate() is called after loading when implemented
- FieldError wraps load errors with field name context

### What This Repo MUST NOT Contain

- Configuration file parsing (YAML, TOML, JSON)
- Configuration watching or hot-reload
- Remote configuration management beyond secret providers
- Environment variable prefixing or namespacing

## Review Priorities

1. Resolution order: secret > env > default must be enforced per field without exception
2. Required field enforcement: missing required values must error, not silently zero
3. Type conversion: all documented types must convert correctly with clear error on failure
4. Secret fallthrough: ErrSecretNotFound must continue resolution, other errors must propagate
5. Nested struct handling: recursive loading must process all levels
6. Validation: post-load Validate() must run after all fields are populated

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Resolution order wrong (env before secret) | Critical |
| Required field silently gets zero value | Critical |
| Type conversion produces wrong value | Critical |
| Secret error other than ErrSecretNotFound silently ignored | High |
| Nested struct field not loaded | High |
| Validator not called when implemented | High |
| FieldError missing field name | Medium |
| Unsupported type silently gets zero value | Medium |
| Bool parsing rejects valid input (1/0, t/f) | Low |

## Standing Concerns

- Sentinel tag registration in init() — verify tags are registered before any Load call
- Secret providers may have latency — verify context propagation for cancellation
- Comma-separated []string parsing — verify trimming and edge cases (empty elements)
- Pointer fields — verify nil vs zero value distinction
- Vault key format path/to/secret:field — verify field extraction edge cases

## Out of Scope

- No config file support is intentional — fig is for env/secret/default only
- sentinel dependency is intentional for struct tag caching
- Secret provider implementations in submodules is intentional — import only what you need
