# Mission: chisel

AST-aware code chunking for semantic search and embeddings.

## Purpose

Parse source code into meaningful semantic units (functions, classes, methods, types) with preserved context for embedding and vector search pipelines. A central Chunker routes requests by language to provider implementations.

Chisel exists because embedding raw source files produces poor search results — semantic chunking by function, method, and type boundaries produces embeddings that match how developers think about code.

## What This Package Contains

- `Chunker` router dispatching by language to registered providers
- `Provider` interface for language-specific parsing
- `Chunk` type with content, symbol name, kind, line range, and parent context chain
- Go provider using stdlib `go/parser` (zero external dependencies)
- Markdown provider using string scanning (zero external dependencies)
- TypeScript/JavaScript provider using tree-sitter
- Python provider using tree-sitter
- Rust provider using tree-sitter
- 10 semantic kinds: Function, Method, Class, Interface, Type, Enum, Constant, Variable, Section, Module
- Dependency isolation via go.work — each provider is a separate module

## What This Package Does NOT Contain

- Embedding generation — chisel produces chunks, vex produces embeddings
- Vector storage or search
- Code formatting or transformation
- Language detection — callers specify the language

## Ecosystem Position

Chisel is consumed by applications that need code chunking for embedding pipelines (e.g., vicky for code search).

## Design Constraints

- Core + Go + Markdown have zero external dependencies
- Tree-sitter providers require CGO — isolated in separate modules
- Providers are stateless and thread-safe — safe to reuse across goroutines
- Chunker is safe for concurrent reads; Register should not be called concurrently with Chunk

## Success Criteria

A developer can:
1. Chunk source code in Go, TypeScript, JavaScript, Python, Rust, and Markdown
2. Get semantic units with symbol names, kinds, line ranges, and parent context
3. Use chunks directly in embedding pipelines for vector search
4. Import only the language providers they need (dependency isolation)
5. Add custom language providers via the Provider interface

## Non-Goals

- Embedding or vector generation
- Code search or retrieval
- Language detection or inference
- Code transformation or formatting
- Supporting every programming language (extensible via Provider interface)
