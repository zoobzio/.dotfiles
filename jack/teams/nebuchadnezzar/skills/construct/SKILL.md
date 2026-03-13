---
name: construct
description: Build API entities — models, stores, handlers, wire types, transformers, boundaries, migrations, clients
---

# Construct

Building the mechanical parts of an API. Each sub-file covers one entity type — read the one that matches what you are building.

| Concern | File | When to Read |
|---------|------|-------------|
| Domain models | `models.md` | Creating a struct in `models/` |
| Storage overview | `stores.md` | Choosing a store variant or understanding the storage layer |
| Database stores | `stores-database.md` | Building a SQL-backed store with `sum.Database[T]` |
| Bucket stores | `stores-bucket.md` | Building a blob store with `grub.Bucket[T]` |
| Key-value stores | `stores-kv.md` | Building a KV store with `grub.Store[T]` |
| Index stores | `stores-index.md` | Building a vector store with `grub.Index[T]` |
| HTTP handlers | `handlers.md` | Creating API endpoints with rocco |
| Wire types | `wire.md` | Creating request/response types for the API boundary |
| Transformers | `transformers.md` | Creating pure mapping functions between models and wire types |
| Boundaries | `boundaries.md` | Adding encryption, hashing, or masking at system boundaries |
| Migrations | `migrations.md` | Creating database schema changes with goose |
| External clients | `clients.md` | Wrapping external APIs with resilience patterns |

Do not load all sub-files upfront. Read the specific sub-file when the current task requires building that entity type.
