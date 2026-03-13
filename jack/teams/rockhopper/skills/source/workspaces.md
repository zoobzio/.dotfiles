# Workspaces

Multi-module workspace, testing submodule, and provider submodule patterns observed across zoobzio packages.

## Testing Submodule

Every zoobzio package isolates its testing infrastructure in a separate Go module:

```
sentinel/
├── go.mod              # github.com/zoobzio/sentinel
├── *.go
└── testing/
    ├── go.mod          # github.com/zoobzio/sentinel/testing
    ├── helpers.go
    └── helpers_test.go

pipz/
├── go.mod              # github.com/zoobzio/pipz
├── *.go
└── testing/
    ├── go.mod          # github.com/zoobzio/pipz/testing
    ├── helpers.go
    ├── helpers_test.go
    ├── benchmarks/
    └── integration/
```

### Why a Separate Module

- **Dependency isolation** — testing helpers may import test frameworks, mocks, or heavier packages that consumers of the main module should never transitively depend on
- **Clean `go.sum`** — the main module's dependency tree stays minimal
- **Opt-in** — consumers `go get github.com/zoobzio/pipz/testing` only if they need test helpers

### Testing Module Structure

| File / Directory | Purpose |
|-----------------|---------|
| `helpers.go` | Consumer-facing test helpers, mock types |
| `helpers_test.go` | Tests for the helpers themselves |
| `benchmarks/` | Performance benchmarks |
| `integration/` | Integration tests that depend on external services or state |

## Provider Submodules

When a package has multiple backend implementations, each lives in its own submodule:

```
zyn/
├── go.mod              # github.com/zoobzio/zyn
├── go.work             # Workspace for development
├── *.go
├── anthropic/
│   └── go.mod          # github.com/zoobzio/zyn/anthropic
├── gemini/
│   └── go.mod          # github.com/zoobzio/zyn/gemini
├── openai/
│   └── go.mod          # github.com/zoobzio/zyn/openai
└── testing/
    └── go.mod          # github.com/zoobzio/zyn/testing
```

### Why Separate Modules

- **Pick your provider** — consumers import only the provider they use, not all of them
- **Isolated SDK dependencies** — each provider brings its own SDK; consumers don't get all three
- **Independent versioning** — provider modules can be updated without bumping the core module

## go.work for Development

The workspace file coordinates multi-module development:

```
// zyn/go.work
use (
    .              // Core module
    ./anthropic    // Provider implementations
    ./gemini
    ./openai
    ./testing      // Test utilities
)
```

### When to Use go.work

- When developing a package with submodules (providers, testing)
- When `go test ./...` needs to span multiple modules
- When local changes span the core module and a submodule

### Conventions

- `go.work` lives at the repository root
- `go.work.sum` is committed (tracks workspace dependency hashes)
- All submodules are listed in the `use` directive
- No `replace` directives in `go.work` — replace belongs in individual `go.mod` files during development, removed before release

## Build Tags for Test Helpers

Main package code that exists only for testing uses the `testing` build tag:

```go
//go:build testing

package sentinel

// Clear resets the cache. Available only in test builds.
func (c *Cache) Clear() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.store = make(map[string]Metadata)
}
```

**When to use build tags vs the testing submodule:**

| Mechanism | When to use |
|-----------|------------|
| `//go:build testing` | Internal helpers that touch unexported state (test-only methods on package types) |
| `testing/` submodule | Consumer-facing helpers, mocks, benchmarks, integration tests |

## Dependency Direction

```
sentinel  ←  capitan  ←  pipz  ←  zyn
(zero deps)  (zero deps)  (capitan)  (pipz, capitan)
```

- Foundation packages (sentinel, capitan) have zero external dependencies
- Higher-level packages depend only on lower-level zoobzio packages
- External dependencies are minimal and deliberate (`google/uuid`)

## Anti-Patterns

| Anti-pattern | Zoobzio approach |
|-------------|-----------------|
| Test helpers in main module | Separate `testing/` submodule |
| All providers in one module | Separate submodule per provider |
| `replace` in committed go.mod | `replace` only during local dev, removed before release |
| Testing infra in `_test.go` files | Consumer-facing helpers in `testing/` module |
| Flat dependency graph | Layered: foundation → middleware → application |

## Checklist

- [ ] Testing infrastructure in a separate `testing/` submodule with its own `go.mod`
- [ ] Provider implementations in separate submodules (when applicable)
- [ ] `go.work` at repository root listing all submodules
- [ ] Internal test helpers use `//go:build testing` in the main package
- [ ] Consumer-facing test helpers in the `testing/` module
- [ ] No `replace` directives in committed `go.mod` files
- [ ] Dependencies flow downward — foundation packages have zero external deps
