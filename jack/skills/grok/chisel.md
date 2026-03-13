# Chisel

Deep understanding of `github.com/zoobzio/chisel` — AST-aware code chunking for semantic search and embeddings.

## Core Concepts

Chisel parses source code into meaningful semantic units (functions, classes, methods, types) with preserved context for embedding and vector search pipelines. A central `Chunker` routes requests by language to provider implementations. Go and Markdown use stdlib (zero deps); TypeScript, Python, Rust use tree-sitter (CGO).

- **Chunker** routes chunking requests by language to registered providers
- **Provider** interface implements language-specific parsing
- **Chunk** represents a semantic unit with content, symbol, kind, line range, and parent context
- Dependencies are isolated per provider submodule — import only what you need

**Dependencies:** None for core + Go + Markdown; tree-sitter for TypeScript/Python/Rust

## Public API

### Core Types

```go
type Language string
const (
    Go, TypeScript, JavaScript, Python, Rust, Markdown Language
)

type Kind string
const (
    KindFunction, KindMethod, KindClass, KindInterface,
    KindType, KindEnum, KindConstant, KindVariable,
    KindSection, KindModule Kind
)
```

### Chunk

```go
type Chunk struct {
    Content   string   // Full source (includes comments, docstrings)
    Symbol    string   // Name (function, class, method — may include receiver)
    Kind      Kind     // Semantic category
    StartLine int      // 1-indexed
    EndLine   int      // 1-indexed
    Context   []string // Parent chain (empty for top-level)
}
```

### Provider Interface

```go
type Provider interface {
    Chunk(ctx context.Context, filename string, content []byte) ([]Chunk, error)
    Language() Language
}
```

### Chunker

```go
func New(providers ...Provider) *Chunker
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Chunk` | `Chunk(ctx, lang, filename, content) ([]Chunk, error)` | Route to provider |
| `Register` | `Register(p Provider)` | Add/replace provider |
| `Languages` | `Languages() []Language` | All registered languages |
| `HasProvider` | `HasProvider(lang) bool` | Check if provider exists |

## Language Providers

### Go (`chisel/golang`)

`golang.New() *Provider` — uses stdlib `go/parser`, zero external dependencies.

| Kind | Extracts |
|------|----------|
| `KindModule` | Package documentation |
| `KindFunction` | Function declarations |
| `KindMethod` | Methods (symbol: `"Type.Method"`, context: `["type Type"]`) |
| `KindClass` | Struct definitions |
| `KindInterface` | Interface definitions |
| `KindType` | Type aliases |

Includes doc comments. Requires valid Go syntax. ~32µs on 50-line files.

### Markdown (`chisel/markdown`)

`markdown.New() *Provider` — simple string scanning, zero external dependencies.

| Kind | Extracts |
|------|----------|
| `KindSection` | ATX-style headers (`#`, `##`, etc.) |

Content extends until next header of equal/higher level. Builds context chain for nesting. Never returns error. ~4µs on 50-line files.

### TypeScript (`chisel/typescript`)

`typescript.New() *Provider` (TypeScript), `typescript.NewJavaScript() *Provider` (JavaScript) — tree-sitter.

| Kind | Extracts |
|------|----------|
| `KindFunction` | Functions + arrow functions (`<anonymous>` for unlabeled) |
| `KindMethod` | Methods (context: parent class) |
| `KindClass` | Class declarations |
| `KindInterface` | Interface declarations (TS only) |
| `KindType` | Type aliases (TS only) |

Error recovery for partial code. ~313µs on 50-line files.

### Python (`chisel/python`)

`python.New() *Provider` — tree-sitter.

| Kind | Extracts |
|------|----------|
| `KindFunction` | Top-level `def` |
| `KindMethod` | Methods inside classes (context: parent class) |
| `KindClass` | Class definitions |

Decorators included in content. Docstrings extracted and prepended. ~328µs on 50-line files.

### Rust (`chisel/rust`)

`rust.New() *Provider` — tree-sitter.

| Kind | Extracts |
|------|----------|
| `KindFunction` | Functions |
| `KindMethod` | Methods in impl blocks (context: impl type) |
| `KindType` | Struct definitions |
| `KindEnum` | Enum definitions |
| `KindInterface` | Trait definitions |
| `KindClass` | Impl blocks |
| `KindModule` | Module declarations |

~293µs on 50-line files.

## Thread Safety

All providers are stateless and thread-safe. Reuse instances across goroutines.

Chunker is safe for concurrent reads (routing). Register should not be called concurrently with Chunk.

## File Layout

```
chisel/
├── api.go           # Language, Kind, Chunk, Provider interface
├── chunker.go       # Chunker router
├── golang/          # Go provider (stdlib)
├── markdown/        # Markdown provider (string scanning)
├── typescript/      # TypeScript/JavaScript provider (tree-sitter)
├── python/          # Python provider (tree-sitter)
├── rust/            # Rust provider (tree-sitter)
└── testing/
    └── helpers.go   # AssertChunkCount, AssertHasSymbol, FindBySymbol, CountByKind
```

Dependency isolation via go.work — each provider is a separate module.

## Common Patterns

**Multi-language routing:**

```go
c := chisel.New(golang.New(), typescript.New(), python.New(), markdown.New())
chunks, err := c.Chunk(ctx, chisel.Go, "main.go", source)
```

**Embedding pipeline:**

```go
chunks, _ := provider.Chunk(ctx, filename, content)
for _, chunk := range chunks {
    vec := embedder.Embed(chunk.Content)
    store(vec, chunk.Symbol, chunk.Kind, chunk.StartLine, chunk.Context)
}
```

## Ecosystem

Chisel is consumed by:
- **vicky** — code search and retrieval (chunks → pgvector storage)
