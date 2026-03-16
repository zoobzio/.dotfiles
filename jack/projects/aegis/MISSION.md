# Mission: aegis

Service mesh for Go microservices with automatic mTLS and discovery.

## Purpose

Provide a gRPC-based service mesh with automatic mTLS certificate generation, peer management, topology synchronization, and typed service clients. A Node is the central unit — it hosts a MeshServer (gRPC), manages Peer connections, tracks cluster state in Topology, and exposes health status.

Aegis exists because Go microservices need secure inter-service communication with peer discovery, topology awareness, and load-balanced service access without external mesh infrastructure.

## What This Package Contains

- Node type as the mesh participant — server, peer manager, topology, health
- MeshServer implementing gRPC MeshService protocol (Ping, Health, NodeInfo, Topology)
- PeerManager maintaining authenticated connections to other nodes
- Topology tracking cluster-wide view of all nodes and their services
- ServiceClientPool with round-robin load-balanced access to services across the mesh
- ServiceClient[T] for typed gRPC service access
- NodeBuilder for fluent node construction
- TLS with automatic self-signed cert generation or explicit cert loading
- TLS sources: file, environment variable, Vault
- Health checking with built-in ping and function checkers
- Caller identity extraction from gRPC context via mTLS certificates
- Topology merge for convergent cluster state

## What This Package Does NOT Contain

- Service discovery protocols (DNS, Consul, etcd)
- Traffic management (routing rules, canary, A/B testing)
- Observability (tracing, metrics) — delegate to aperture
- Rate limiting or circuit breaking — delegate to pipz

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sctx` | Certificate-based security contexts for mTLS authorization |
| `gRPC` | Transport and service protocol |

Aegis is consumed by applications for microservice mesh networking.

## Design Constraints

- gRPC-only transport — no HTTP/REST mesh protocol
- One MeshServer per Node
- Topology merge is convergent — nodes converge on consistent cluster view
- TLS cert generation is self-signed — production should use explicit certs
- ServiceClientPool uses atomic round-robin counters for load balancing
- All components (Health, Topology, PeerManager, ServiceClientPool) are thread-safe

## Success Criteria

A developer can:
1. Create mesh nodes with automatic or explicit mTLS certificates
2. Discover and connect to peers with authenticated gRPC connections
3. Synchronize topology across the mesh for consistent cluster view
4. Access services via typed clients with round-robin load balancing
5. Monitor node health with pluggable health checkers
6. Extract caller identity from mTLS certificates in gRPC handlers

## Non-Goals

- External service discovery (Consul, etcd, DNS-SD)
- Traffic management policies
- Observability integration (tracing, metrics)
- Non-gRPC transport protocols
