---
name: grok
description: Understand the zoobzio Go ecosystem — package map, dependency flows, shared conventions. Read before working on any zoobzio package or reviewing cross-package changes.
user-invocable: false
allowed-tools: Read
---

# Grok

Understand the zoobzio ecosystem — what packages exist, how they relate, and what role each plays.

## When to Use

- Before working on any zoobzio package
- Before designing integrations between packages
- When you need to understand how a package fits into the broader ecosystem
- When reviewing code that crosses package boundaries

## Execution

1. Read this file for ecosystem orientation
2. Read the package-specific grok file for the package relevant to your task

## Ecosystem Overview

Zoobzio is a collection of Go packages that follow a shared philosophy: minimal dependencies, type safety through generics, explicit boundaries, and composition over inheritance.

### Package Map

#### Foundation (zero dependencies)

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [sentinel](sentinel.md) | Struct introspection and metadata extraction | erd, soy, rocco, atom, cereal, zyn |
| [capitan](capitan.md) | Type-safe event coordination | pipz, aperture, herald, ago, rocco, soy |
| [clockz](clockz.md) | Deterministic time mocking and testing | capitan, pipz |

#### Data & Query

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [astql](astql.md) | Type-safe SQL AST with DBML schema validation and multi-dialect rendering | soy, edamame |
| [dbml](dbml.md) | DBML (Database Markup Language) generation from Go structs | soy, astql |
| [atom](atom.md) | Type-segregated struct decomposition into typed maps | soy |
| [soy](soy.md) | Type-safe schema-validated SQL query builder | Applications |
| [edamame](edamame.md) | Statement-driven query execution — typed queries without magic strings | Applications |
| [erd](erd.md) | Entity relationship diagram generation from sentinel metadata | Applications |

#### Pipeline & Stream

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [pipz](pipz.md) | Composable, type-safe data processing pipelines | zyn, herald, ago, flume |
| [flume](flume.md) | Dynamic pipeline factory for pipz — schema-driven construction, hot-reloading | Applications |
| [streamz](streamz.md) | Type-safe stream processing primitives for Go channels | Applications |

#### HTTP & API

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [openapi](openapi.md) | OpenAPI 3.1 as native Go types — build, read, write specs | rocco |
| [check](check.md) | Fluent struct validation with struct tag verification | rocco |
| [rocco](rocco.md) | Type-safe HTTP framework with automatic OpenAPI generation | Applications |

#### AI & LLM

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [zyn](zyn.md) | Structured LLM interactions via typed synapses | Applications |
| [chit](chit.md) | Conversation lifecycle controller for LLM-powered applications | Applications |
| [cogito](cogito.md) | Structured reasoning and LLM orchestration | Applications |
| [chisel](chisel.md) | AST-aware code chunking for semantic search and embeddings | vicky |

#### Search & ML

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [lucene](lucene.md) | Type-safe search queries for Elasticsearch/OpenSearch with schema validation | Applications |
| [vecna](vecna.md) | Schema-validated filter builder for vector databases | Applications |
| [vex](vex.md) | Type-safe embedding vector generation with provider-agnostic reliability | Applications |
| [tendo](tendo.md) | Composable tensor library for Go with GPU acceleration | Applications |

#### Observability & Events

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [aperture](aperture.md) | Config-driven OpenTelemetry bridge for capitan events | Applications |
| [herald](herald.md) | Message broker bridge (Kafka, NATS, SQS, etc.) for capitan events | ago, Applications |
| [ago](ago.md) | Event-driven workflow orchestration via capitan signals | Applications |

#### Configuration & Serialization

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [fig](fig.md) | Configuration loading from environment, secrets, and defaults via struct tags | Applications |
| [flux](flux.md) | Reactive configuration synchronization with validation and rollback | Applications |
| [cereal](cereal.md) | Boundary-aware serialization — encrypt for storage, mask for APIs, hash on receive | Applications |

#### Storage

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [grub](grub.md) | Provider-agnostic storage — unified interface for key-value, blob, SQL, vector | Applications |
| [scio](scio.md) | URI-based data catalog with atomic operations across storage types | Applications |

#### Infrastructure & Security

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [aegis](aegis.md) | Service mesh for Go microservices with automatic mTLS and discovery | Applications |
| [sctx](sctx.md) | Certificate-based security contexts — mTLS certs to typed authorization tokens | aegis |
| [slush](slush.md) | Service locator with composable access checks (services behind gates) | Applications |

#### Application Framework

| Package | Purpose | Key Consumers |
|---------|---------|---------------|
| [sum](sum.md) | Application framework unifying HTTP, data, configuration, services | ergo, nestor |

### Dependency Flow

```
sentinel (foundation — zero dependencies)
    ├── atom (decomposes structs into typed maps)
    ├── erd (reads relationships)
    ├── soy (reads field tags via astql/dbml)
    ├── rocco (reads metadata for OpenAPI)
    ├── cereal (reads field metadata for boundary serialization)
    └── zyn (reads metadata for JSON schema)

clockz (foundation — zero dependencies)
    ├── capitan (testable time)
    └── pipz (testable backoff/timeout)

capitan (foundation — zero dependencies)
    ├── pipz (emits signals for retry, timeout, circuit breaker)
    │   ├── zyn (pipelines for LLM request processing)
    │   ├── herald (pipelines for publish/subscribe)
    │   ├── ago (pipelines for workflow steps)
    │   └── flume (dynamic pipeline factory)
    ├── aperture (observes events, exports OTEL traces/metrics/logs)
    ├── herald (bridges events to/from message brokers)
    │   └── ago (publishes workflow events to brokers)
    ├── ago (coordinates workflows via signals)
    ├── rocco (lifecycle signals)
    └── soy (query signals)

astql (SQL AST)
    ├── soy (query building)
    └── edamame (statement execution)

openapi (OpenAPI types)
    └── rocco (spec generation)

check (validation)
    └── rocco (struct validation)

sctx (security contexts)
    └── aegis (mTLS authorization)
```

### Shared Conventions

All zoobzio packages follow:

- **Zero or minimal production dependencies** — stdlib first, zoobzio second, external last
- **Test isolation via build tags** — `//go:build testing` for test helpers
- **Consumer-facing test helpers** — packages provide helpers so consumers can test their integrations
- **Generics over interface{}** — type parameters for compile-time safety
- **Context everywhere** — every I/O operation accepts `context.Context`
- **Errors as data** — semantic errors (`ErrNotFound`, `ErrNotStruct`) consistent across implementations
- **Composition** — one interface per abstraction level, immutable processors, mutable connectors

### Package-Specific Documentation

Each documented package has its own grok file with deep API reference, types, patterns, and anti-patterns:

- [`sentinel.md`](sentinel.md) — Struct introspection library
- [`capitan.md`](capitan.md) — Type-safe event coordination
- [`pipz.md`](pipz.md) — Composable data processing pipelines
- [`zyn.md`](zyn.md) — Typed LLM interactions via synapses
- [`erd.md`](erd.md) — Entity relationship diagram generation
- [`soy.md`](soy.md) — Type-safe SQL query builder
- [`rocco.md`](rocco.md) — Type-safe HTTP framework with OpenAPI generation
- [`aperture.md`](aperture.md) — OpenTelemetry bridge for capitan events
- [`herald.md`](herald.md) — Message broker bridge (11 provider implementations)
- [`ago.md`](ago.md) — Event-driven workflow orchestration
- [`clockz.md`](clockz.md) — Deterministic time mocking and testing
- [`astql.md`](astql.md) — Type-safe SQL AST with multi-dialect rendering
- [`dbml.md`](dbml.md) — DBML generation from Go structs
- [`atom.md`](atom.md) — Type-segregated struct decomposition
- [`openapi.md`](openapi.md) — OpenAPI 3.1 as native Go types
- [`check.md`](check.md) — Fluent struct validation
- [`cereal.md`](cereal.md) — Boundary-aware serialization
- [`fig.md`](fig.md) — Configuration loading via struct tags
- [`edamame.md`](edamame.md) — Statement-driven query execution
- [`flume.md`](flume.md) — Dynamic pipeline factory for pipz
- [`streamz.md`](streamz.md) — Stream processing primitives for channels
- [`chit.md`](chit.md) — Conversation lifecycle controller
- [`cogito.md`](cogito.md) — Structured reasoning and LLM orchestration
- [`chisel.md`](chisel.md) — AST-aware code chunking
- [`lucene.md`](lucene.md) — Type-safe Elasticsearch/OpenSearch queries
- [`vecna.md`](vecna.md) — Schema-validated vector DB filter builder
- [`vex.md`](vex.md) — Provider-agnostic embedding generation
- [`tendo.md`](tendo.md) — Composable tensor library with GPU acceleration
- [`scio.md`](scio.md) — URI-based data catalog with atomic operations
- [`flux.md`](flux.md) — Reactive configuration synchronization
- [`grub.md`](grub.md) — Provider-agnostic storage (key-value, blob, SQL, vector, search)
- [`aegis.md`](aegis.md) — Service mesh with automatic mTLS
- [`sctx.md`](sctx.md) — Certificate-based security contexts
- [`slush.md`](slush.md) — Type-safe service locator with guards
- [`sum.md`](sum.md) — Application framework
