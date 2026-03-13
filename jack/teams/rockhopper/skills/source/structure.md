# Structure

File organisation, naming, and package layout conventions observed across zoobzio packages.

## File Naming

Files are named for the primary type or concern they contain. One dominant concept per file.

```
sentinel/
├── api.go           # Public API — Sentinel orchestrator, Inspect/TryInspect
├── cache.go         # Cache type and operations
├── extraction.go    # Type extraction logic
├── metadata.go      # Metadata types and helpers
├── relationship.go  # Relationship discovery
├── reset.go         # Testing helpers (build tag: testing)

capitan/
├── api.go           # Public API — Signal, Key, Field interfaces
├── config.go        # Configuration and validation
├── event.go         # Event type and pooling
├── fields.go        # Key implementations per type
├── listener.go      # Listener type
├── observer.go      # Observer type
├── service.go       # Capitan singleton orchestrator
├── worker.go        # Worker goroutine implementation

pipz/
├── api.go           # Core interfaces — Chainable, Cloner, Processor, Identity
├── schema.go        # Schema and Flow types
├── error.go         # Error type with context
├── signals.go       # Capitan signal definitions
├── pipeline.go      # Pipeline composition helpers
├── sequence.go      # One connector per file
├── fallback.go      #
├── race.go          #
├── concurrent.go    #
├── retry.go         #
├── handle.go        #
├── filter.go        #
├── ...              #
├── apply.go         # One processor per file
├── transform.go     #
├── effect.go        #
├── enrich.go        #
├── mutate.go        #

zyn/
├── api.go           # Core interfaces — Provider, Validator
├── service.go       # Service type for typed LLM calls
├── options.go       # Reliability options
├── session.go       # Session context
├── prompt.go        # Prompt building
├── schema.go        # Schema utilities
├── hooks.go         # Integration points
├── mock.go          # Testing utilities
├── binary.go        # One synapse type per file
├── classification.go#
├── extraction.go    #
├── transform.go     #
├── analyze.go       #
├── ranking.go       #
├── sentiment.go     #
├── convert.go       #
```

### Conventions

- `api.go` holds the package's public contract — core interfaces, primary types, top-level functions
- One processor/connector/synapse type per file, named after the type
- Supporting infrastructure gets its own file by concern: `error.go`, `signals.go`, `schema.go`
- Files are named in lowercase, singular, no underscores unless compound (`circuitbreaker.go`)

## Package Layout

The public API lives at the package root. Most of the package's surface area should be importable from the top-level path — that's what consumers see first.

```
sentinel/
├── go.mod
├── *.go          # Public API at root
└── testing/      # Separate module for test infrastructure
    ├── go.mod
    └── *.go
```

Subdivide when the code warrants it:

| Directory | When to use |
|-----------|------------|
| `internal/` | Implementation details that must not leak to consumers — unexported-by-module, not just unexported-by-convention |
| `cmd/` | When building CLIs — each binary gets its own subdirectory |
| Submodules (`./foo/`) | When a chunk of distinct logic has its own dependency graph (providers, testing infrastructure) |
| `testing/` | Separate module for consumer-facing test helpers, benchmarks, integration tests |

The existing packages (sentinel, capitan, pipz) are flat because they are focused libraries with no internal-only logic worth hiding at the module level. Zyn uses submodules for providers because each brings its own SDK dependency. The pattern scales — add structure when there is a reason, not preemptively.

## Import Grouping

Two groups separated by a blank line: stdlib, then everything else.

```go
import (
    "context"
    "errors"
    "sync"
    "time"

    "github.com/zoobzio/capitan"
    "github.com/zoobzio/pipz"
)
```

No separation between zoobzio packages and third-party packages — all external imports in one group.

## Receiver Naming

Single-letter receivers for all types, derived from the type name:

```go
func (l *Listener) Close() { }
func (o *Observer) Drain(ctx context.Context) error { }
func (k GenericKey[T]) Name() string { }
func (c *Sequence[T]) Process(ctx context.Context, data T) (T, error) { }
func (h *Handle[T]) Process(ctx context.Context, input T) (T, error) { }
func (s *Service[T]) Execute(ctx context.Context, ...) (T, error) { }
```

No abbreviated names (`lst`, `obs`). No full names (`listener`, `observer`). Always single letter.

## Comment Style

Doc comments on all public types and functions. First line is the summary sentence.

```go
// Inspect returns comprehensive metadata for a type.
// Panics if T is not a struct type.
func Inspect[T any]() Metadata {

// Chainable defines the interface for any component that can process
// values of type T. This interface enables composition of different
// processing components that operate on the same type.
//
// Key design principles:
//   - Context support for timeout and cancellation
//   - Type safety through generics (no interface{})
//   - Error propagation for fail-fast behavior
type Chainable[T any] interface {
```

Implementation comments are minimal — only where the code isn't self-explanatory.

## Checklist

- [ ] Files named for their primary type or concern
- [ ] One dominant concept per file
- [ ] `api.go` contains the public contract
- [ ] Public API lives at the package root
- [ ] `internal/` used for implementation details that must not leak to consumers
- [ ] `cmd/` used for CLI binaries
- [ ] Submodules used for distinct logic with its own dependency graph
- [ ] Import groups: stdlib, blank line, external
- [ ] Receivers are single-letter
- [ ] Doc comments on all exports, summary sentence first
- [ ] No subdirectory structure without a concrete reason
