# Guides

Write how-to guides — configuration, testing, best practices, and feature-specific guides. These are procedural docs for consumers who know the basics and need to accomplish something specific.

## Philosophy

A guide answers "how do I do X?" The reader already understands the package (they've read the learn section). They need step-by-step instruction for a specific task. Guides are practical, not conceptual. Show the configuration, explain when to adjust it, warn about pitfalls.

## Execution

1. Identify which guides are needed for this package
2. Write each guide per specifications
3. Verify frontmatter, examples, and cross-references

## Specifications

### Directory Structure

```
docs/
└── 2.guides/
    ├── 1.configuration.md
    ├── 2.testing.md
    ├── 3.best-practices.md
    └── 4.[feature].md        (continue numbering per feature)
```

Not all packages need all guides. Write what's warranted:

| Guide | When to write |
|-------|--------------|
| Configuration | Package has functional options or configurable behaviour |
| Testing | Package provides test helpers or has testing patterns consumers should follow |
| Best Practices | Package has non-obvious production patterns or common pitfalls |
| Feature guides | Specific features complex enough to warrant dedicated guidance |

### Guide Structure

Every guide follows this shape:

| Section | Content |
|---------|---------|
| Opening | What this guide covers — one sentence |
| Prerequisites | What the reader should already know or have done |
| Conceptual framing | Brief context — when to use this, when not to |
| Step-by-step content | The actual guidance, with examples |
| Configuration tables | When options exist — option, default, description |
| Common pitfalls | What goes wrong and how to avoid it |
| Related docs | Links to related guides, concepts, reference |

### Configuration Guide

Document every configurable behaviour:

```markdown
## Options

| Option | Default | Description |
|--------|---------|-------------|
| `WithBufferSize(n)` | 16 | Event queue buffer size per worker |
| `WithPanicHandler(fn)` | nil | Custom handler for recovered panics |

### When to Adjust

**Buffer size:** Increase when event producers are bursty and consumers are slow.
The default of 16 handles most workloads. If you see backpressure signals,
start at 64 and measure.
```

"When to adjust" is what separates a useful configuration guide from a parameter dump. Every option should explain the decision, not just the default.

### Testing Guide

Document how consumers should test their code that uses this package:

```markdown
## Test Helpers

The `testing` submodule provides helpers for testing code that uses pipz:

` ` `go
import pipt "github.com/zoobzio/pipz/testing"

func TestMyPipeline(t *testing.T) {
    mock := pipt.NewMockProcessor[MyData](t, "mock-proc")
    mock.SetReturn(expected)
    // ...
}
` ` `

## Build Tags

Internal test helpers use `//go:build testing`. Enable with:

` ` `bash
go test -tags testing ./...
` ` `
```

### Best Practices Guide

Document production patterns and pitfalls:

```markdown
## Graceful Shutdown

Always close processors in reverse order of construction:

` ` `go
defer pipeline.Close()
` ` `

## Error Handling

Check context errors before retrying:

` ` `go
if errors.Is(err, context.Canceled) {
    return err // Don't retry cancellation
}
` ` `
```

### Feature Guides

For features complex enough to warrant their own doc. Follow the standard guide structure. Name the file after the feature: `4.relationships.md`, `5.signals.md`, `6.reliability.md`.

## Anti-Patterns

| Anti-pattern | Approach |
|-------------|----------|
| Configuration as parameter dump | Every option explains when and why to adjust |
| Guide without prerequisites | State what the reader should already know |
| Guide without examples | Every step has a code example |
| Guide that re-explains concepts | Link to concepts, don't repeat them |
| Catch-all "Advanced Usage" guide | One guide per feature — focused and findable |

## Checklist

- [ ] Only guides warranted by the package are written
- [ ] Each guide has a clear scope — one task or feature
- [ ] Configuration options include "when to adjust" guidance
- [ ] Testing guide covers helpers, build tags, and consumer patterns
- [ ] Best practices guide covers production patterns and pitfalls
- [ ] Examples are complete and compile
- [ ] All frontmatter present (see `frontmatter.md`)
- [ ] Cross-references use numbered paths
- [ ] Common pitfalls documented for each guide
