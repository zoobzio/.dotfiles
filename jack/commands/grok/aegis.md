# Aegis

Deep understanding of `github.com/zoobzio/aegis` — service mesh for Go microservices with automatic mTLS and discovery.

## Core Concepts

Aegis provides a gRPC-based service mesh with automatic mTLS certificate generation, peer management, topology synchronization, and typed service clients. A `Node` is the central unit — it hosts a `MeshServer` (gRPC), manages `Peer` connections via `PeerManager`, tracks cluster state in `Topology`, and exposes health status.

- **Node** is the mesh participant — server, peer manager, topology, health
- **MeshServer** implements the gRPC MeshService protocol (Ping, Health, NodeInfo, Topology)
- **PeerManager** maintains authenticated connections to other nodes
- **Topology** is the cluster-wide view of all nodes and their services
- **ServiceClientPool** provides round-robin load-balanced access to services across the mesh
- **TLS** — automatic self-signed cert generation or explicit cert loading

**Dependencies:** `google.golang.org/grpc`, `google.golang.org/protobuf`

## Public API

### Node

```go
func NewNode(id, name string, nodeType NodeType, address string) *Node
```

```go
type Node struct {
    ID          string
    Name        string
    Type        NodeType
    Address     string
    Services    []ServiceInfo
    Health      *HealthInfo
    PeerManager *PeerManager
    MeshServer  *MeshServer
    Topology    *Topology
    TLSConfig   *TLSConfig
}
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `EnableTLS` | `EnableTLS(certDir string) error` | Load or generate mTLS certs |
| `Validate` | `Validate() error` | Check required fields |
| `SetHealth` | `SetHealth(status, message, err)` | Update health state |
| `GetHealth` | `GetHealth() (HealthStatus, string)` | Current health |
| `IsHealthy` | `IsHealthy() bool` | Quick check |
| `CheckHealth` | `CheckHealth(ctx, checker) error` | Run health checker |
| `StartServer` | `StartServer() error` | Start gRPC server |
| `StopServer` | `StopServer()` | Stop gRPC server |
| `AddPeer` | `AddPeer(info PeerInfo) error` | Connect to peer |
| `RemovePeer` | `RemovePeer(peerID) error` | Disconnect peer |
| `GetPeer` | `GetPeer(peerID) (*Peer, bool)` | Lookup peer |
| `GetAllPeers` | `GetAllPeers() []*Peer` | All connected peers |
| `PingPeer` | `PingPeer(ctx, peerID) (*PingResponse, error)` | Ping a peer |
| `GetPeerHealth` | `GetPeerHealth(ctx, peerID) (*HealthResponse, error)` | Query peer health |
| `GetPeerNodeInfo` | `GetPeerNodeInfo(ctx, peerID) (*NodeInfoResponse, error)` | Query peer info |
| `SyncTopology` | `SyncTopology(ctx, peerID) error` | Sync topology with one peer |
| `SyncTopologyWithAllPeers` | `SyncTopologyWithAllPeers(ctx) error` | Sync with all peers |
| `GetTopologyVersion` | `GetTopologyVersion() int64` | Current topology version |
| `GetMeshNodes` | `GetMeshNodes() []NodeInfo` | All known nodes |
| `Shutdown` | `Shutdown() error` | Graceful shutdown |

### NodeBuilder

```go
func NewNodeBuilder() *NodeBuilder
```

| Method | Signature |
|--------|-----------|
| `WithID` | `WithID(id) *NodeBuilder` |
| `WithName` | `WithName(name) *NodeBuilder` |
| `WithType` | `WithType(nodeType) *NodeBuilder` |
| `WithAddress` | `WithAddress(address) *NodeBuilder` |
| `WithServices` | `WithServices(services...) *NodeBuilder` |
| `WithServiceRegistration` | `WithServiceRegistration(r ServiceRegistrar) *NodeBuilder` |
| `WithCertDir` | `WithCertDir(certDir) *NodeBuilder` |
| `WithTLSOptions` | `WithTLSOptions(opts) *NodeBuilder` |
| `Build` | `Build() (*Node, error)` |

Convenience: `NewSecureNode(id, name, nodeType, address, certDir) (*Node, error)`

### ServiceClientPool

```go
func NewServiceClientPool(node *Node) *ServiceClientPool
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `GetConn` | `GetConn(ctx, name, version) (*grpc.ClientConn, error)` | Get connection to service provider |
| `Close` | `Close() error` | Close all connections |

### ServiceClient[T]

```go
func NewServiceClient[T any](pool *ServiceClientPool, name, version string, newClient func(grpc.ClientConnInterface) T) *ServiceClient[T]
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Get` | `Get(ctx) (T, error)` | Get typed client with round-robin selection |

### Topology

```go
func NewTopology() *Topology
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `AddNode` | `AddNode(info NodeInfo) error` | Register node |
| `RemoveNode` | `RemoveNode(nodeID) error` | Deregister node |
| `UpdateNode` | `UpdateNode(info NodeInfo) error` | Update node info |
| `GetNode` | `GetNode(nodeID) (NodeInfo, bool)` | Lookup node |
| `GetAllNodes` | `GetAllNodes() []NodeInfo` | All known nodes |
| `GetVersion` | `GetVersion() int64` | Topology version |
| `Clone` | `Clone() *Topology` | Deep copy |
| `Merge` | `Merge(other *Topology) bool` | Merge (returns true if changed) |
| `NodeCount` | `NodeCount() int` | Count |
| `GetServiceProviders` | `GetServiceProviders(name, version) []NodeInfo` | Find providers |
| `GetNodesByService` | `GetNodesByService(name) []NodeInfo` | Find by service name |

### PeerManager

```go
func NewPeerManager(nodeID string) *PeerManager
```

| Method | Signature |
|--------|-----------|
| `SetTLSConfig` | `SetTLSConfig(*TLSConfig)` |
| `AddPeer` | `AddPeer(PeerInfo) error` |
| `RemovePeer` | `RemovePeer(peerID) error` |
| `GetPeer` | `GetPeer(peerID) (*Peer, bool)` |
| `GetAllPeers` | `GetAllPeers() []*Peer` |
| `GetPeersByType` | `GetPeersByType(NodeType) []*Peer` |
| `PingPeer` | `PingPeer(ctx, peerID) (*PingResponse, error)` |
| `GetPeerHealth` | `GetPeerHealth(ctx, peerID) (*HealthResponse, error)` |
| `GetPeerNodeInfo` | `GetPeerNodeInfo(ctx, peerID) (*NodeInfoResponse, error)` |
| `SyncTopology` | `SyncTopology(ctx, peerID, version) (*TopologySyncResponse, error)` |
| `Close` | `Close() error` |
| `Count` | `Count() int` |
| `IsConnected` | `IsConnected(peerID) bool` |

### Health

```go
type HealthStatus string
const (
    HealthStatusHealthy   HealthStatus = "healthy"
    HealthStatusUnhealthy HealthStatus = "unhealthy"
    HealthStatusUnknown   HealthStatus = "unknown"
)

type HealthChecker interface {
    Check(ctx context.Context) error
    Name() string
}
```

Built-in: `NewPingHealthChecker(name)`, `NewFunctionHealthChecker(name, fn)`.

### TLS

```go
func LoadOrGenerateTLS(nodeID, certDir string) (*TLSConfig, error)

type TLSConfig struct {
    Certificate tls.Certificate
    CertPool    *x509.CertPool
    ServerName  string
}
```

| Method | Signature |
|--------|-----------|
| `GetServerTLSConfig` | `GetServerTLSConfig() *tls.Config` |
| `GetClientTLSConfig` | `GetClientTLSConfig(serverName) *tls.Config` |

Advanced: `LoadTLSConfig(opts *TLSOptions) (*TLSConfig, error)` with `CertSourceFile`, `CertSourceEnv`, `CertSourceVault`.

### Context

```go
func CallerFromContext(ctx context.Context) (*Caller, error)
func MustCallerFromContext(ctx context.Context) *Caller

type Caller struct {
    NodeID      string
    Certificate *x509.Certificate
}
```

### Supporting Types

```go
type NodeType string
const NodeTypeGeneric NodeType = "generic"

type ServiceInfo struct {
    Name    string
    Version string
}

type PeerInfo struct {
    ID      string
    Address string
    Type    NodeType
}

type NodeInfo struct {
    ID, Name, Address string
    Type              NodeType
    Services          []ServiceInfo
    JoinedAt, UpdatedAt time.Time
}

type ServiceRegistrar func(*grpc.Server)
```

## gRPC Protocol

MeshService defines five RPCs: `Ping`, `GetHealth`, `GetNodeInfo`, `SyncTopology`, `GetTopology`.

## Error Types

| Error | Purpose |
|-------|---------|
| `ErrNoProviders` | No providers available for service |
| `ErrNoTLSConfig` | Node has no TLS configuration |
| `ErrNoPeerInfo` | No peer info in gRPC context |
| `ErrNoTLSInfo` | No TLS info in peer |
| `ErrNoCertificate` | No client certificate |

## Thread Safety

- **HealthInfo** — `sync.RWMutex` protected
- **Topology** — `sync.RWMutex` protected
- **PeerManager** — `sync.RWMutex` protected
- **ServiceClientPool** — `sync.RWMutex` with double-checked locking; `atomic.Uint64` for round-robin counters
- **MeshServer** — safe for concurrent gRPC handlers
- **Node** — delegates to thread-safe components

## File Layout

```
aegis/
├── node.go            # Node type and mesh operations
├── node_builder.go    # Fluent NodeBuilder
├── server.go          # MeshServer gRPC implementation
├── client.go          # ServiceClientPool and ServiceClient[T]
├── peer.go            # Peer and PeerManager
├── topology.go        # Topology management
├── health.go          # HealthInfo, HealthChecker
├── service.go         # ServiceInfo
├── context.go         # Caller extraction from gRPC context
├── tls.go             # TLS cert generation and loading
├── tls_config.go      # TLSOptions and advanced cert sources
├── mesh.proto         # Protocol buffer definition
├── mesh.pb.go         # Generated proto messages
├── mesh_grpc.pb.go    # Generated gRPC bindings
└── testing/           # Test helpers
```

## Common Patterns

**Create a secure node:**

```go
node, _ := aegis.NewNodeBuilder().
    WithID("node-1").
    WithName("api-gateway").
    WithAddress("localhost:9090").
    WithServices(aegis.ServiceInfo{Name: "gateway", Version: "v1"}).
    WithCertDir("/etc/certs").
    Build()
node.StartServer()
defer node.Shutdown()
```

**Connect peers:**

```go
node.AddPeer(aegis.PeerInfo{ID: "node-2", Address: "10.0.0.2:9090"})
node.SyncTopologyWithAllPeers(ctx)
```

**Type-safe service client:**

```go
pool := aegis.NewServiceClientPool(node)
client := aegis.NewServiceClient(pool, "users", "v1", pb.NewUserServiceClient)
userSvc, _ := client.Get(ctx) // Round-robin across providers
```

**Caller identity in handlers:**

```go
caller, _ := aegis.CallerFromContext(ctx)
fmt.Println(caller.NodeID, caller.Certificate.Subject.CommonName)
```

## Ecosystem

Aegis depends on:
- **sctx** — certificate-based security contexts (for mTLS authorization)
- **gRPC** — transport and service protocol

Aegis is consumed by:
- Applications for microservice mesh networking
