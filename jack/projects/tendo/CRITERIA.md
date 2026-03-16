# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- All operations produce numerically correct results
- Shape validation catches incompatible operations before computation
- CPU and CUDA backends produce identical results for the same operations
- Memory pool correctly allocates, frees, and reuses storage without data corruption
- Device transfer preserves tensor data exactly
- All operations implement pipz.Chainable[*Tensor] correctly
- Broadcasting follows standard rules (NumPy-compatible)

### What This Repo MUST NOT Contain

- Automatic differentiation or autograd
- Model definition or parameter management
- Training optimizers
- Data loading logic

## Review Priorities

1. Numerical correctness: wrong math in tensor operations is critical
2. Shape validation: incompatible shapes must error before computation, not produce garbage
3. Memory safety: pool reuse must not leak data between tensors, Free must not double-free
4. Device correctness: CPU and CUDA must produce identical results
5. Broadcasting: must follow standard rules without silent data corruption
6. Float16/BFloat16 conversion: precision loss must be within acceptable bounds

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Numerically incorrect result | Critical |
| Memory corruption from pool reuse | Critical |
| Shape mismatch not caught | Critical |
| CPU/CUDA result divergence beyond floating point tolerance | High |
| Broadcasting produces wrong shape | High |
| Device transfer loses data | High |
| Memory leak (pool never frees) | High |
| Dropout applies during inference mode | Medium |
| Float16 conversion loses more precision than expected | Medium |
| Missing capitan signal for operation | Low |

## Standing Concerns

- Memory pool size-class rounding means slight over-allocation — verify no excessive waste
- CUDA backend requires CGO — verify build tags isolate it correctly
- Dropout behavior depends on context training mode — verify mode propagation
- BatchNorm has different behavior in training vs inference — verify mode is respected
- Tensor not thread-safe — verify documentation is clear about caller responsibility

## Out of Scope

- No autograd is intentional — tendo is for inference, not training
- gonum dependency is intentional for CPU numerical computing
- CUDA backend requires CGO — inherent to GPU access
- Individual tensors not thread-safe is by design — ML inference is typically sequential per batch
