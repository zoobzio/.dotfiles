# Pipeline Integration Testing

Testing pipeline composition, stage interaction, error propagation, and resilience under real conditions.

## Stage Interaction

Test that stages compose correctly in sequence, with each stage's output feeding the next.

```go
func TestPipelineStageSequence(t *testing.T) {
    pipeline := sum.NewPipeline(
        stages.Validate(),
        stages.Transform(),
        stages.Persist(realStore),
    )

    carrier := sum.NewCarrier()
    carrier.Set("input", rawPayload)

    result, err := pipeline.Execute(context.Background(), carrier)
    AssertNoError(t, err)

    // Verify each stage contributed to the carrier
    if result.Get("validated") == nil {
        t.Fatal("validate stage did not run")
    }
    if result.Get("transformed") == nil {
        t.Fatal("transform stage did not run")
    }
    if result.Get("persisted") == nil {
        t.Fatal("persist stage did not run")
    }
}
```

Test that stage ordering matters — rearranging stages should produce different results or fail predictably.

```go
func TestPipelineStageOrder(t *testing.T) {
    // Transform before validate — should still work but produce different state
    pipeline := sum.NewPipeline(
        stages.Transform(),
        stages.Validate(), // validates transformed data, not raw
    )

    carrier := sum.NewCarrier()
    carrier.Set("input", rawPayload)

    result, err := pipeline.Execute(context.Background(), carrier)
    AssertNoError(t, err)

    // Verify the validation ran against transformed data
    validated := result.Get("validated")
    if validated == nil {
        t.Fatal("validate stage did not run")
    }
}
```

## Error Propagation

Test that errors from any stage propagate correctly through the pipeline.

```go
func TestPipelineErrorPropagation(t *testing.T) {
    pipeline := sum.NewPipeline(
        stages.Validate(),
        stages.FailingStage(), // always returns an error
        stages.Persist(realStore),
    )

    carrier := sum.NewCarrier()
    carrier.Set("input", rawPayload)

    _, err := pipeline.Execute(context.Background(), carrier)
    if err == nil {
        t.Fatal("expected pipeline error")
    }

    // Persist should not have run
    // Verify no data was written to the store
    results, _ := realStore.List(context.Background())
    if len(results) != 0 {
        t.Fatal("persist stage ran despite earlier failure")
    }
}
```

Test that error context is preserved — the error should identify which stage failed.

```go
func TestPipelineErrorContext(t *testing.T) {
    pipeline := sum.NewPipeline(
        stages.Validate(),
        stages.Transform(),
    )

    carrier := sum.NewCarrier()
    carrier.Set("input", invalidPayload)

    _, err := pipeline.Execute(context.Background(), carrier)
    if err == nil {
        t.Fatal("expected validation error")
    }

    if !strings.Contains(err.Error(), "validate") {
        t.Fatalf("error should identify the failing stage: %v", err)
    }
}
```

## Resilience Wrappers

Test timeout, retry, and circuit breaker behaviour under real conditions.

### Timeout

```go
func TestPipelineTimeout(t *testing.T) {
    slow := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        select {
        case <-time.After(5 * time.Second):
            return nil
        case <-ctx.Done():
            return ctx.Err()
        }
    })

    pipeline := sum.NewPipeline(
        sum.WithTimeout(100*time.Millisecond),
        slow,
    )

    carrier := sum.NewCarrier()
    _, err := pipeline.Execute(context.Background(), carrier)

    if !errors.Is(err, context.DeadlineExceeded) {
        t.Fatalf("expected deadline exceeded, got: %v", err)
    }
}
```

### Retry

```go
func TestPipelineRetry(t *testing.T) {
    attempts := 0
    flaky := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        attempts++
        if attempts < 3 {
            return fmt.Errorf("transient failure")
        }
        return nil
    })

    pipeline := sum.NewPipeline(
        sum.WithRetry(3, 10*time.Millisecond),
        flaky,
    )

    carrier := sum.NewCarrier()
    _, err := pipeline.Execute(context.Background(), carrier)
    AssertNoError(t, err)

    if attempts != 3 {
        t.Fatalf("expected 3 attempts, got %d", attempts)
    }
}

func TestPipelineRetryExhausted(t *testing.T) {
    failing := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        return fmt.Errorf("permanent failure")
    })

    pipeline := sum.NewPipeline(
        sum.WithRetry(3, 10*time.Millisecond),
        failing,
    )

    carrier := sum.NewCarrier()
    _, err := pipeline.Execute(context.Background(), carrier)

    if err == nil {
        t.Fatal("expected error after retries exhausted")
    }
}
```

### Circuit Breaker

```go
func TestPipelineCircuitBreaker(t *testing.T) {
    cb := sum.NewCircuitBreaker(sum.CircuitConfig{
        Threshold:   3,
        ResetAfter:  1 * time.Second,
    })

    failing := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        return fmt.Errorf("service unavailable")
    })

    pipeline := sum.NewPipeline(
        sum.WithCircuitBreaker(cb),
        failing,
    )

    carrier := sum.NewCarrier()

    // Trip the circuit breaker
    for i := 0; i < 3; i++ {
        pipeline.Execute(context.Background(), carrier)
    }

    // Next call should fail fast without executing the stage
    start := time.Now()
    _, err := pipeline.Execute(context.Background(), carrier)
    elapsed := time.Since(start)

    if err == nil {
        t.Fatal("expected circuit breaker error")
    }

    if elapsed > 10*time.Millisecond {
        t.Fatalf("circuit breaker should fail fast, took %v", elapsed)
    }
}
```

## WorkerPool Concurrency

Test that WorkerPool executes stages concurrently and collects results correctly.

```go
func TestWorkerPoolConcurrency(t *testing.T) {
    var mu sync.Mutex
    var running int
    var maxRunning int

    stage := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        mu.Lock()
        running++
        if running > maxRunning {
            maxRunning = running
        }
        mu.Unlock()

        time.Sleep(50 * time.Millisecond)

        mu.Lock()
        running--
        mu.Unlock()
        return nil
    })

    pool := sum.NewWorkerPool(4)
    carriers := make([]*sum.Carrier, 8)
    for i := range carriers {
        carriers[i] = sum.NewCarrier()
    }

    err := pool.Execute(context.Background(), stage, carriers)
    AssertNoError(t, err)

    if maxRunning < 2 {
        t.Fatalf("expected concurrent execution, max running was %d", maxRunning)
    }

    if maxRunning > 4 {
        t.Fatalf("exceeded pool size: max running was %d", maxRunning)
    }
}
```

Test that WorkerPool propagates errors from any worker:

```go
func TestWorkerPoolError(t *testing.T) {
    stage := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        if c.Get("fail") != nil {
            return fmt.Errorf("worker failure")
        }
        return nil
    })

    pool := sum.NewWorkerPool(4)
    carriers := []*sum.Carrier{
        sum.NewCarrier(),
        sum.NewCarrier(),
    }
    carriers[1].Set("fail", true)

    err := pool.Execute(context.Background(), stage, carriers)
    if err == nil {
        t.Fatal("expected worker error")
    }
}
```

## Carrier State Accumulation

Test that carrier state accumulates correctly across pipeline stages.

```go
func TestCarrierStateAccumulation(t *testing.T) {
    addHeader := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        c.Set("header", "parsed")
        return nil
    })

    addBody := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        // Can read state from previous stage
        if c.Get("header") == nil {
            return fmt.Errorf("expected header state from previous stage")
        }
        c.Set("body", "processed")
        return nil
    })

    addFooter := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        // Can read state from all previous stages
        if c.Get("header") == nil || c.Get("body") == nil {
            return fmt.Errorf("expected accumulated state")
        }
        c.Set("footer", "appended")
        return nil
    })

    pipeline := sum.NewPipeline(addHeader, addBody, addFooter)
    carrier := sum.NewCarrier()

    result, err := pipeline.Execute(context.Background(), carrier)
    AssertNoError(t, err)

    // All three stages should have contributed state
    for _, key := range []string{"header", "body", "footer"} {
        if result.Get(key) == nil {
            t.Fatalf("missing carrier state: %s", key)
        }
    }
}
```

Test that carrier state is isolated between pipeline executions:

```go
func TestCarrierIsolation(t *testing.T) {
    stage := stages.NewStage(func(ctx context.Context, c *sum.Carrier) error {
        c.Set("count", 1)
        return nil
    })

    pipeline := sum.NewPipeline(stage)

    // Two separate executions should not share state
    carrier1 := sum.NewCarrier()
    carrier2 := sum.NewCarrier()

    pipeline.Execute(context.Background(), carrier1)
    pipeline.Execute(context.Background(), carrier2)

    // Modifying carrier1 after execution should not affect carrier2
    if carrier1 == carrier2 {
        t.Fatal("carriers should be independent instances")
    }
}
```
