# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Each provider extracts correct semantic units for its language
- Chunk symbol names correctly identify the code entity
- Chunk kinds accurately categorize entities (Function, Method, Class, etc.)
- Line ranges (StartLine, EndLine) are accurate and 1-indexed
- Context chains correctly reflect parent relationships (e.g., method → class)
- Go and Markdown providers have zero external dependencies
- Content includes associated comments and docstrings

### What This Repo MUST NOT Contain

- Embedding generation or vector operations
- Storage or search logic
- Language detection
- External dependencies in core, Go provider, or Markdown provider

## Review Priorities

1. Extraction accuracy: missing functions, wrong boundaries, or incorrect symbols are critical
2. Context correctness: parent chain must accurately reflect code structure
3. Line range accuracy: wrong ranges produce incorrect source navigation
4. Zero-dep compliance: core + Go + Markdown must not import external packages
5. Error recovery: tree-sitter providers should handle partial/invalid code gracefully
6. Provider isolation: tree-sitter CGO dependencies must not leak into core module

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Function/method not extracted | Critical |
| Wrong symbol name for extracted chunk | High |
| Line range off by more than 1 | High |
| External dependency in core/Go/Markdown | High |
| Context chain missing parent | High |
| Comments/docstrings not included in content | Medium |
| Tree-sitter provider crashes on invalid code | Medium |
| Missing Kind categorization | Medium |
| Anonymous function handling inconsistent | Low |

## Standing Concerns

- Go provider uses stdlib go/parser which requires valid Go syntax — verify error handling for partial files
- Tree-sitter providers handle error recovery differently per language — verify consistency
- Markdown provider uses simple string scanning — verify edge cases with fenced code blocks containing # characters
- Method symbol naming varies by language (Go: "Type.Method", Python: just "method" with context) — verify consistency within each provider

## Out of Scope

- No embedding generation is intentional — chisel chunks, vex embeds
- Tree-sitter CGO requirement is inherent to AST parsing — isolated in separate modules
- Not all languages supported is by design — Provider interface enables extension
- Anonymous function naming varies by language — intentional per-language behavior
