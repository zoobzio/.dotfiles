# Tendo

Deep understanding of `github.com/zoobzio/tendo` — composable tensor library for Go with GPU acceleration.

## Core Concepts

Tendo provides multi-dimensional tensor computation with pluggable backends (CPU, CUDA), composable operations via pipz, memory pooling, and comprehensive observability via capitan. All operations implement `pipz.Chainable[*Tensor]` for pipeline composition.

- **Tensor** wraps backend-specific storage with shape, stride, and device metadata
- **Backend** interfaces separate compute from storage (CPU, CUDA)
- **Operators** are chainable pipz processors — compose into pipelines
- **Pool** reuses memory allocations to reduce GC/malloc pressure
- **Context** carries training mode, pool, and trace ID

**Dependencies:** `pipz` (operation composition), `capitan` (observability), `gonum` (numerical computing), `tokenizers` (text tokenization)

## Public API

### Tensor

```go
type Tensor struct { /* storage, shape, stride, offset, pool */ }
```

**Shape/Metadata:**

| Method | Behaviour |
|--------|-----------|
| `Shape()` | Logical dimensions |
| `Stride()` | Memory layout |
| `Dim()` | Number of dimensions |
| `Size(dim)` | Size of specific dimension |
| `Numel()` | Total elements |
| `Device()` | Which device (CPU/CUDA) |
| `DType()` | Element type |
| `IsContiguous()` | Memory layout check |

**Data Access:**

| Method | Behaviour |
|--------|-----------|
| `Data() []float32` | Underlying float32 elements |
| `Int64Data() []int64` | Underlying int64 elements |
| `Clone()` | Deep copy |
| `Contiguous()` | Ensure contiguous layout |
| `Free()` | Release memory (returns to pool if set) |

### Data Types

```go
type DType uint8
const ( Float32, Float16, BFloat16, Int64 DType )
```

`SetDefaultDType(d)` / `DefaultDType()` — thread-safe global default.

Type casting operators: `ToFloat32()`, `ToFloat16()`, `ToBFloat16()`, `ToDType(DType)`.

Float16/BFloat16 conversion: `Float32ToFloat16`, `Float16ToFloat32`, `Float32ToBFloat16`, `BFloat16ToFloat32`.

### Devices

```go
type DeviceType uint8
const ( CPU, CUDA DeviceType )

func CPUDevice() Device
func CUDADevice(idx int) Device
```

Transfer operators: `To(device)`, `ToCPU()`, `ToGPU(idx)`.

### Tensor Creation

| Function | Purpose |
|----------|---------|
| `Empty(shape...)` | Uninitialized |
| `Zeros(shape...)` | Zero-filled |
| `Ones(shape...)` | Ones-filled |
| `Full(value, shape...)` | Scalar-filled |
| `FromSlice(data, shape...)` | From float32 slice |
| `Rand(shape...)` | Uniform [0,1) |
| `RandN(shape...)` | Standard normal |
| `Eye(n)` | Identity matrix |
| `Arange(start, end, step)` | 1D range |
| `Linspace(start, end, n)` | Evenly-spaced values |
| `ZerosLike(t)` / `OnesLike(t)` / `EmptyLike(t)` / `RandLike(t)` / `RandNLike(t)` | Shape-matching |

Variants: `*On(backend, ...)` for explicit backend, `Must*` for panic-on-error.

### Backend Interfaces

| Interface | Operations |
|-----------|-----------|
| `CoreBackend` | Storage, device info, tensor factory |
| `ArithmeticBackend` | Add, Sub, Mul, Div, Pow, Neg, Abs, Exp, Log, Sqrt, Square, Sign, Sin, Cos |
| `MatrixBackend` | MatMul, Transpose |
| `NeuralBackend` | Activations, normalization, convolution, pooling, loss, embedding, shape ops |
| `ReduceBackend` | Sum, Mean, Max, Min, Var, Std, Prod, ArgMax, ArgMin |
| `CompareBackend` | Clamp, Where, Tril |

## Operations

### Element-wise

**Unary:** `ReLU`, `Sigmoid`, `Tanh`, `GELU`, `SiLU`, `Neg`, `Abs`, `Exp`, `Log`, `Sqrt`, `Square`, `Sign`, `Sin`, `Cos`

**Binary:** `Add`, `Sub`, `Mul`, `Div`, `Pow` — with broadcasting

### Matrix

`MatMul(a, b)` — 2D or batched. `Transpose(dim0, dim1)`, `T()`.

### Shape

`Reshape`, `View`, `Squeeze`/`SqueezeDim`, `Unsqueeze`, `Flatten`, `Slice`, `Narrow`, `Expand`, `Permute`, `Cat`, `Stack`

### Reduction

`Sum`, `Mean`, `Max`, `Min`, `Var`, `Std`, `Prod`, `ArgMax`, `ArgMin` — all with `dims[]` and `keepdim` parameters.

### Activation

`Softmax(t, dim)`, `LogSoftmax(t, dim)`, `LeakyReLU(t, negativeSlope)`, `Dropout(t, p, training)` — dropout respects training mode from context.

### Normalization

| Operator | Input Shape | Normalizes Over |
|----------|------------|-----------------|
| `BatchNorm2d` | [N,C,H,W] | N,H,W per channel |
| `LayerNorm` | Any | Last N dimensions |
| `RMSNorm` | Any | Last N dimensions (no bias) |
| `GroupNorm` | [N,C,...] | Group-wise |
| `InstanceNorm2d` | [N,C,H,W] | Per-instance |

### Convolution

`Conv2d(input, weight, padding, stride, dilation, groups)` — [N,C_in,H,W] → [N,C_out,H',W']

`ConvTranspose2d(input, weight, padding, outputPadding, stride, dilation, groups)`

### Pooling

`MaxPool2d`, `AvgPool2d`, `AdaptiveAvgPool2d`, `AdaptiveMaxPool2d`

### Loss

| Operator | Input | Target | Output |
|----------|-------|--------|--------|
| `MSELoss` | Any | Same shape | Scalar |
| `L1Loss` | Any | Same shape | Scalar |
| `CrossEntropyLoss` | [N,C] logits | [N] indices | Scalar |
| `NLLLoss` | [N,C] log-probs | [N] indices | Scalar |

Reduction modes: `"none"`, `"mean"`, `"sum"`.

### Comparison/Selection

`Clamp(t, min, max)`, `Where(condition, x, y)`, `Tril(t, k)`

### Embedding

`Embedding(weight, indices)` — weight [vocab,embed_dim], indices arbitrary shape → indices.shape + [embed_dim].

## Memory Pool

```go
pool := tendo.NewPool()
pool.SetMaxCacheSize(1 << 30) // 1 GB limit
```

| Method | Behaviour |
|--------|-----------|
| `AllocCPU(numel, dtype)` | Allocate CPU storage |
| `FreeCPU(storage)` | Return to pool |
| `AllocCUDA(numel, dtype, device)` | Allocate CUDA memory |
| `FreeCUDA(ptr, numel, dtype, device)` | Return to pool |
| `Clear()` | Clear all cached blocks |
| `Stats()` | Pool statistics |

Context integration: `WithPool(ctx, pool)`, `PoolFromContext(ctx)`, `NewTensorFromPool(pool, shape, dtype)`.

Size classes use power-of-2 rounding. FIFO eviction. Thread-safe (mutex-protected).

## Context Integration

| Function | Purpose |
|----------|---------|
| `WithTraining(ctx)` | Enable training mode |
| `WithInference(ctx)` | Disable training (default) |
| `IsTraining(ctx)` | Check mode |
| `WithPool(ctx, pool)` | Set memory pool |
| `WithTraceID(ctx, id)` | Set trace ID for observability |

## Error Types

| Type | Purpose |
|------|---------|
| `BackendError` | Backend unavailability (`ErrNoBackend`, `ErrCUDANotAvailable`) |
| `CUDAError` | CUDA operation failures (Message, Code) |
| `DeviceError` | Device type mismatch (Expected, Got) |
| `DeviceMismatchError` | Incompatible devices (A, B) |
| `ShapeError` | Shape-related failures (Op, Message, ShapeA, ShapeB) |
| `ErrNotImplemented` | Operation not in backend (Op, Backend) |
| `ErrShapeMismatch` | Data/shape mismatch in constructors |
| `ErrZeroStep` | Arange step is zero |

All custom types implement `Is()` for `errors.Is()` matching.

## Capitan Signals

60+ operation signals (`OpAdd`, `OpMatMul`, `OpReLU`, `OpConv2d`, etc.) plus lifecycle signals (`TensorCreated`, `TensorFreed`, `TensorTransfer`) and memory signals (`PoolAlloc`, `PoolFree`).

40+ typed keys for event fields: `KeyInput`, `KeyOutput`, `KeyShape`, `KeyDevice`, `KeyTraceID`, `KeyWeight`, `KeyBias`, `KeyPadding`, `KeyKernelSize`, `KeyEpsilon`, etc.

## Thread Safety

- `DefaultDType()` / `SetDefaultDType()` — RWMutex protected
- `Pool` — all methods mutex-protected
- Individual tensors — NOT thread-safe (caller responsible)
- Backend state — assume single-threaded per context

## File Layout

```
tendo/
├── api.go            # Backend interface definitions
├── tensor.go         # Tensor type and methods
├── storage.go        # Storage interface, CPUStorage
├── device.go         # Device, DeviceType
├── dtype.go          # DType, conversions
├── float16.go        # Float16/BFloat16 conversion
├── constructors.go   # Tensor creation functions
├── activation.go     # ReLU, Sigmoid, Tanh, GELU, SiLU, Softmax, Dropout
├── elementwise.go    # Add, Sub, Mul, Div, Pow, unary math
├── reduce.go         # Sum, Mean, Max, Min, Var, Std, Prod, ArgMax/Min
├── matrix.go         # MatMul, Transpose
├── shape.go          # Reshape, Squeeze, Unsqueeze, Slice, Cat, Stack
├── norm.go           # BatchNorm, LayerNorm, RMSNorm, GroupNorm, InstanceNorm
├── conv.go           # Conv2d, ConvTranspose2d
├── pool.go           # MaxPool2d, AvgPool2d, Adaptive variants
├── loss.go           # MSELoss, L1Loss, CrossEntropyLoss, NLLLoss
├── embedding.go      # Embedding lookup
├── transfer.go       # Device transfer (To, ToCPU, ToGPU)
├── ops.go            # Context utilities, helper builders
├── mempool.go        # Memory pool implementation
├── signals.go        # Observability signals and keys
├── helpers.go        # Pipeline composition helpers
├── safetensors.go    # SafeTensors file format support
├── cpu/              # CPU backend implementation
├── cuda/             # CUDA backend (GPU acceleration)
├── nn/               # Neural network layers
└── testing/          # Test helpers
```

## Common Patterns

**Pipeline composition:**

```go
forward := pipz.NewSequence(id,
    tendo.NewMatMul(backend, weights),
    tendo.NewAdd(backend, bias),
    tendo.NewReLU(backend),
)
output, _ := forward.Process(ctx, input)
```

**Device transfer:**

```go
gpuTensor, _ := tendo.ToGPU(0).Process(ctx, cpuTensor)
cpuResult, _ := tendo.ToCPU().Process(ctx, gpuTensor)
```

**Memory pooling:**

```go
pool := tendo.NewPool()
ctx := tendo.WithPool(context.Background(), pool)
t, _ := tendo.NewTensorFromContext(ctx, []int{1000, 1000}, tendo.Float32)
t.Free() // Returns to pool
```

**Training vs inference:**

```go
ctx := tendo.WithTraining(context.Background())
// Dropout applies during training
output, _ := dropout.Process(ctx, input)

ctx = tendo.WithInference(ctx)
// Dropout is no-op during inference
output, _ = dropout.Process(ctx, input)
```

## Ecosystem

Tendo depends on:
- **pipz** — operation composition
- **capitan** — observability

Tendo is consumed by:
- Applications for tensor computation and neural network inference
