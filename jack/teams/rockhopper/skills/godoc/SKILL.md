# Add Godoc

Add or update godoc comments for a Go source file. Documentation should explain *why* and *when*, not just *what*.

## Philosophy

Godoc is the first thing a consumer reads. It's not decoration — it's the API's user interface. A well-documented function tells you what it does, when to use it, what to expect, and what can go wrong — all without reading the source. A poorly documented function forces every consumer to reverse-engineer intent from implementation.

Write for the person who will call this function at 2am during an incident. They need clarity, not cleverness.

## Execution

1. Read checklist.md in this skill directory
2. Read the source file thoroughly
3. Identify all exported symbols requiring documentation
4. Write godoc comments following Go conventions
5. Verify with `go doc` output

## Specifications

### What Requires Documentation

Every exported symbol MUST have a godoc comment:

| Symbol | Required | Format |
|--------|----------|--------|
| Package | Yes | `// Package foo provides...` |
| Type (struct) | Yes | `// TypeName describes/represents...` |
| Type (interface) | Yes | `// TypeName defines/describes...` |
| Function | Yes | `// FunctionName does...` |
| Method | Yes | `// MethodName does...` |
| Constant (group) | Yes | Comment above `const` block |
| Constant (individual) | When non-obvious | Inline or above |
| Variable (exported) | Yes | `// VarName is/holds...` |
| Sentinel error | Yes | `// ErrFoo is returned when...` |

Unexported symbols: document when the logic is non-obvious. Skip for simple, self-evident implementations.

### Comment Format

Go convention: comments begin with the symbol name.

```go
// Client manages connections to the remote service.
// It is safe for concurrent use.
type Client struct { ... }

// NewClient creates a Client with the given options.
// It returns an error if the configuration is invalid.
func NewClient(opts ...Option) (*Client, error) { ... }

// Close releases all resources held by the Client.
// It is safe to call Close multiple times.
func (c *Client) Close() error { ... }
```

### Package Comments

Every package needs a package comment. For single-file packages, place it in the primary file. For multi-file packages, use `doc.go`.

```go
// Package auth provides authentication and authorization primitives
// for the sentinel ecosystem.
//
// It supports token-based authentication with configurable providers
// and role-based access control for API endpoints.
package auth
```

Content:
- What the package provides (one sentence)
- Key concepts or types (brief)
- Usage context (when would someone import this)

### Function and Method Comments

Structure for non-trivial functions:

```go
// Validate checks the configuration against the schema and returns
// any validation errors found. It does not modify the configuration.
//
// Validate returns nil if the configuration is valid. If multiple
// errors are found, they are returned as a joined error.
func (c *Config) Validate() error { ... }
```

Include when relevant:
- **What it does** (always — first sentence)
- **Return values** (what each return means)
- **Error conditions** (when errors are returned and what kind)
- **Side effects** (if any — mutations, I/O, goroutines spawned)
- **Concurrency safety** (safe for concurrent use? requires locking?)
- **Nil behaviour** (what happens with nil receiver or nil arguments)

### Sentinel Errors

Document when the error is returned, not just what it is:

```go
// ErrNotFound is returned when the requested resource does not exist
// in the store. Callers should check for this error using errors.Is
// to distinguish missing resources from other failures.
var ErrNotFound = errors.New("not found")
```

### Interface Comments

Document the contract, not the implementation:

```go
// Store defines the persistence contract for user records.
// Implementations must be safe for concurrent use.
type Store interface {
    // Get retrieves a user by ID. It returns ErrNotFound if the
    // user does not exist.
    Get(ctx context.Context, id string) (*User, error)
}
```

### Type Comments

For structs, document purpose and usage, not fields:

```go
// Config holds the settings for a Server instance.
// Use NewConfig or load from a configuration file with ConfigFromFile.
// A zero-value Config is not valid — use NewConfig for defaults.
type Config struct { ... }
```

Document individual fields when their purpose isn't self-evident from the name and type:

```go
type Config struct {
    // MaxRetries is the maximum number of retry attempts before
    // giving up. Zero means no retries. Negative values are treated
    // as zero.
    MaxRetries int

    Timeout time.Duration // per-request timeout
}
```

### Deprecated Symbols

Use the `Deprecated:` convention:

```go
// OldFunction does something.
//
// Deprecated: Use NewFunction instead.
func OldFunction() { ... }
```

## Prohibitions

DO NOT:
- Write comments that repeat the function signature in prose (`// SetName sets the name`)
- Add comments to unexported symbols that are self-evident
- Use `@param`, `@return`, or Javadoc-style annotations
- Write comments that describe *implementation* rather than *behaviour*
- Add empty or placeholder comments (`// TODO: document this`)

## Output

A source file where:
- Every exported symbol has a godoc comment starting with its name
- Package has a package comment (in primary file or `doc.go`)
- Comments explain purpose, usage, errors, and concurrency safety
- No Javadoc-style annotations
- No parrot comments that restate the signature
- `go doc ./...` produces clean, useful output
