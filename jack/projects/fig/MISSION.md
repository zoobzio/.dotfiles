# Mission: fig

Configuration loading from environment variables, secret providers, and defaults via struct tags.

## Purpose

Populate Go structs from multiple sources using struct tags with strict priority resolution: secret, env, default, zero value. A single generic entry point handles all configuration loading with optional validation.

Fig exists because configuration loading from multiple sources (environment, secrets, defaults) requires repetitive boilerplate with easy-to-miss edge cases. This package makes configuration a struct tag declaration.

## What This Package Contains

- Load[T] and LoadContext[T] generic entry points for configuration population
- Struct tag system: env, secret, default, required
- Priority resolution: secret > env > default > zero value (per-field)
- SecretProvider interface for pluggable secret backends
- Provider implementations: HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager
- Type conversion for all Go primitives, time.Duration, []string, pointers, TextUnmarshaler
- Validator interface — post-load validation when T implements Validate()
- Nested struct support with recursive loading
- FieldError wrapping with field name context

## What This Package Does NOT Contain

- Configuration file parsing (YAML, TOML, JSON files)
- Configuration watching or hot-reload
- Remote configuration management
- Environment variable prefixing or namespacing

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sentinel` | Struct tag scanning and metadata caching |

Fig is consumed by applications for configuration loading.

## Design Constraints

- Resolution is per-field, priority-ordered
- SecretProvider returns ErrSecretNotFound to fall through to next source
- Sentinel caches metadata per type — repeated Load calls avoid reflection
- Fig has no global mutable state — thread-safe by design
- Validation errors are NOT wrapped in FieldError

## Success Criteria

A developer can:
1. Load configuration from environment variables with a single function call
2. Integrate secret providers (Vault, AWS SM, GCP SM) for sensitive values
3. Declare defaults and required fields via struct tags
4. Validate loaded configuration with custom logic
5. Use nested structs for organized configuration hierarchies
6. Get clear error messages with field names when loading fails

## Non-Goals

- Configuration file formats (YAML, TOML, JSON)
- Watch/reload capabilities
- Remote configuration stores beyond secret providers
- Environment variable prefixing conventions
