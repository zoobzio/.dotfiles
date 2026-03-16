# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- mTLS certificate generation and loading produce valid, usable certificates
- Peer connections are authenticated via mTLS — no unauthenticated connections
- Topology merge converges correctly — no lost nodes, no duplicate entries
- ServiceClientPool round-robin distributes across all providers
- Caller identity extraction from gRPC context returns correct certificate info
- Health status accurately reflects node state
- Graceful shutdown closes all connections and stops the server

### What This Repo MUST NOT Contain

- Service discovery protocols (DNS, Consul, etcd)
- Traffic management or routing rules
- Observability (tracing, metrics)
- Rate limiting or circuit breaking

## Review Priorities

1. TLS correctness: certificate generation must produce valid certs, verification must reject invalid ones
2. Authentication: peer connections must verify mTLS certificates — no bypass path
3. Topology convergence: merge must be idempotent and produce consistent cluster state
4. Service routing: round-robin must distribute across all available providers evenly
5. Shutdown safety: graceful shutdown must close all peer connections and drain in-flight RPCs
6. Caller identity: context extraction must match the actual presenting certificate

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Unauthenticated peer connection accepted | Critical |
| Certificate verification bypassed | Critical |
| Topology merge loses nodes | High |
| Round-robin skips available provider | High |
| Caller identity returns wrong certificate | High |
| Shutdown leaves connections open | High |
| Health check returns wrong status | Medium |
| Self-signed cert generation produces weak keys | Medium |
| NodeBuilder validation misses required field | Low |

## Standing Concerns

- Self-signed cert generation is for development — verify documentation warns about production use
- Topology merge with version tracking — verify no split-brain under concurrent merges
- ServiceClientPool double-checked locking — verify no race in connection creation
- gRPC server stop vs graceful stop — verify in-flight RPCs are drained

## Out of Scope

- gRPC-only transport is intentional — mesh protocol requires bidirectional streaming
- Self-signed certs for development is by design — production uses explicit certs
- No external discovery is intentional — aegis manages its own topology
- sctx dependency is intentional for certificate-based authorization
