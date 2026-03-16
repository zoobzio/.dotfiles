# Mission: tendo

Composable tensor library for Go with GPU acceleration.

## Purpose

Provide multi-dimensional tensor computation with pluggable backends (CPU, CUDA), composable operations via pipz, memory pooling, and comprehensive observability. All operations implement `pipz.Chainable[*Tensor]` for pipeline composition.

Tendo exists because Go lacks a native tensor library with GPU support, composable operations, and production-grade memory management for ML inference workloads.

## What This Package Contains

- Tensor type with shape, stride, device metadata, and data access methods
- Data types: Float32, Float16, BFloat16, Int64 with conversion operators
- Backend interfaces: Core, Arithmetic, Matrix, Neural, Reduce, Compare
- CPU and CUDA backend implementations
- Element-wise operations: arithmetic, trigonometric, activation functions
- Matrix operations: matmul, transpose (2D and batched)
- Shape operations: reshape, view, squeeze, unsqueeze, slice, cat, stack, permute
- Reduction operations: sum, mean, max, min, var, std, argmax, argmin
- Neural network operations: activations, normalization (batch, layer, RMS, group, instance), convolution, pooling, loss functions, embedding
- Memory pool with size-class allocation, FIFO eviction, and context integration
- Device transfer: CPU↔CUDA with explicit operators
- Training/inference mode via context
- SafeTensors file format support
- 60+ capitan signals for operation and memory observability

## What This Package Does NOT Contain

- Automatic differentiation or autograd
- Model definition framework (weight management, parameter registration)
- Training loops or optimizers
- Data loading or preprocessing

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `pipz` | Operation composition into pipelines |
| `capitan` | Operation and memory observability |

Tendo is consumed by applications for tensor computation and neural network inference.

## Design Constraints

- All operations implement `pipz.Chainable[*Tensor]` for pipeline composition
- Individual tensors are NOT thread-safe — caller responsible for synchronization
- Memory pool is thread-safe (mutex-protected)
- Backend interfaces separate compute from storage for pluggable implementations
- Training/inference mode carried via context

## Success Criteria

A developer can:
1. Create and manipulate tensors with full shape, stride, and device metadata
2. Compose operations into pipz pipelines for forward passes
3. Use CPU or CUDA backends through the same API
4. Manage memory efficiently with pooling for inference workloads
5. Load model weights from SafeTensors format
6. Run neural network inference with activations, normalization, convolution, and pooling

## Non-Goals

- Automatic differentiation or training
- Model definition or weight management framework
- Training optimizers (SGD, Adam, etc.)
- Data loading pipelines
