# Benchmarks

Add realistic benchmarks for performance-critical code. Benchmarks must measure what they claim to measure.

## Philosophy

Benchmarks lie by default. A benchmark showing 1M ops/sec means nothing if:
- Input is pre-allocated outside the loop
- Data is cache-hot from previous iteration
- Work is optimised away by the compiler
- Real-world allocation patterns differ
- Contention isn't simulated

This produces honest benchmarks.

## When to Benchmark

- Hot paths (called frequently in production)
- Allocation-sensitive operations
- Concurrent operations (contention matters)
- Operations where performance is a requirement

Do NOT benchmark trivial getters, simple assignments, or code that isn't performance-critical.

## File Placement

Benchmarks live in `testing/benchmarks/`:

```
testing/
└── benchmarks/
    ├── README.md
    └── [feature]_test.go
```

## Naming Convention

`Benchmark[Function]_[Variant]`

Examples:
- `BenchmarkParse`
- `BenchmarkParse_LargeInput`
- `BenchmarkParse_Parallel`
- `BenchmarkParse_ColdCache`

## Naive Pattern Prevention

DO NOT write benchmarks that exhibit these patterns:

| Pattern | Problem | Fix |
|---------|---------|-----|
| Pre-allocated input | Hides allocation cost | Allocate inside loop or use `b.ResetTimer()` |
| Cache-hot data | Unrealistic memory access | Use varying input sizes, cold starts |
| Compiler elimination | Dead code removed | Use result (assign to package-level var) |
| Single goroutine | Hides contention | Add `b.RunParallel()` variant |
| Tiny input | Hides scaling issues | Test across input sizes |
| No allocations check | Hides memory pressure | Always use `b.ReportAllocs()` |

## Realistic Design

Every benchmark SHOULD include:

| Element | Purpose |
|---------|---------|
| `b.ReportAllocs()` | Show allocation impact |
| `b.ResetTimer()` | Exclude setup from measurement |
| `b.StopTimer()`/`b.StartTimer()` | Exclude per-iteration setup |
| Result sink | Prevent compiler optimisation |
| Size variants | Show scaling behaviour |
| Parallel variant | Show contention behaviour |

## Patterns

### Result Sink

```go
var result int // Package-level sink

func BenchmarkCompute(b *testing.B) {
    b.ReportAllocs()
    var r int
    for i := 0; i < b.N; i++ {
        r = Compute(42)
    }
    result = r // Prevent elimination
}
```

### Parallel

```go
func BenchmarkProcess_Parallel(b *testing.B) {
    b.ReportAllocs()
    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            Process(input)
        }
    })
}
```

### Size Variants

```go
func BenchmarkParse(b *testing.B) {
    sizes := []struct {
        name string
        size int
    }{
        {"Small", 100},
        {"Medium", 10_000},
        {"Large", 1_000_000},
    }

    for _, s := range sizes {
        b.Run(s.name, func(b *testing.B) {
            b.ReportAllocs()
            input := generateInput(s.size)
            b.ResetTimer()
            for i := 0; i < b.N; i++ {
                Parse(input)
            }
        })
    }
}
```

## Result Interpretation

| Metric | What it means |
|--------|---------------|
| ns/op | Time per operation |
| B/op | Bytes allocated per operation |
| allocs/op | Number of allocations per operation |

Red flags:
- 0 B/op when allocations expected
- Wildly different parallel vs sequential
- Linear scaling when sub-linear expected
- Suspiciously fast (compiler eliminated work?)

### Comparison

When comparing benchmarks:
- Use `benchstat` for statistical comparison
- Minimum 10 runs for significance (`-count=10`)
- Same hardware, same conditions
- Watch for variance (noisy results)

## Output

Benchmark file(s) that:
- Live in `testing/benchmarks/`
- Use `b.ReportAllocs()` on every benchmark
- Include result sinks to prevent compiler elimination
- Provide size variants for scaling analysis
- Provide parallel variants for concurrency analysis
- Run with `go test -bench=. -benchmem -count=10 ./testing/benchmarks/...`

## Checklist

### Identify Targets
- [ ] What operations are performance-critical?
- [ ] What operations are called frequently (hot paths)?
- [ ] What operations are allocation-sensitive?
- [ ] What operations involve concurrency?

### Write Benchmarks
- [ ] File placed in `testing/benchmarks/`
- [ ] Function naming: `Benchmark[Function]_[Variant]`
- [ ] `b.ReportAllocs()` called
- [ ] Result sink prevents compiler elimination
- [ ] Setup excluded from measurement (`b.ResetTimer()`)
- [ ] Input NOT pre-allocated outside the loop (unless intentional with `b.ResetTimer()`)
- [ ] Size variants where scaling matters
- [ ] Parallel variant (`b.RunParallel()`) for concurrent operations

### Run and Verify
- [ ] `go test -bench=. -benchmem -count=10 ./testing/benchmarks/...` succeeds
- [ ] Results are plausible (not suspiciously fast)
- [ ] B/op is non-zero where allocations are expected
- [ ] Parallel variant shows expected scaling behaviour
- [ ] Baseline results recorded in `testing/benchmarks/README.md`
