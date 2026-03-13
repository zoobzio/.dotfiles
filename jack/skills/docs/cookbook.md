# Cookbook

Write real-world recipes — complete, runnable examples that solve concrete problems. These are the docs consumers reach for when they have a specific use case and want to see how it's done.

## Philosophy

A recipe starts with a scenario, not a concept. "You have a stream of orders and need to validate, enrich, and route them." The reader has a problem. The recipe solves it. Everything in the recipe serves that scenario — setup, code, explanation, and output.

Recipes are not tutorials. Tutorials teach concepts progressively. Recipes assume knowledge and solve problems.

## Execution

1. Identify real-world scenarios the package enables
2. Write each recipe per specifications
3. Verify all code compiles and produces documented output

## Specifications

### Directory Structure

```
docs/
└── 4.cookbook/
    ├── 1.[recipe-name].md
    ├── 2.[recipe-name].md
    └── ...
```

### Recipe Structure

Every recipe follows this shape:

| Section | Content |
|---------|---------|
| Scenario | What the reader is trying to accomplish — one paragraph |
| Setup | Any types, data, or prerequisites the recipe needs |
| Solution | The code, broken into logical steps with annotations |
| What's Happening | Brief explanation of the key decisions |
| Output | Expected result — what the reader should see |
| Variations | Common modifications to the base recipe |

### Scenario

Start with the use case, not the package feature:

```markdown
## Order Processing Pipeline

You receive orders as JSON, need to validate them, enrich with inventory data,
calculate totals, and route to the appropriate fulfilment system. Invalid orders
get logged and skipped. The pipeline must handle 1000+ orders per second.
```

Not: "This recipe demonstrates how to use Sequence, Apply, and Enrich processors."

### Solution Code

Complete and runnable. Annotate key decisions inline:

```go
// Validate first — reject bad data before expensive enrichment
validate := pipz.Apply[*Order](validateID, func(ctx context.Context, order *Order) (*Order, error) {
    if order.Total <= 0 {
        return order, fmt.Errorf("invalid total: %w", ErrValidation)
    }
    return order, nil
})

// Enrich with inventory — external call, may fail
enrich := pipz.Enrich[*Order](enrichID, func(ctx context.Context, order *Order) (*Order, error) {
    stock, err := inventory.Check(ctx, order.SKU)
    if err != nil {
        return order, fmt.Errorf("inventory check: %w", err)
    }
    order.InStock = stock.Available
    return order, nil
})
```

### Annotations

Explain *why*, not *what*. The code shows what. The annotation explains the decision:

- "Validate first — reject bad data before expensive enrichment"
- "Retry with backoff — inventory service has transient failures"
- "Fallback to cached data — better stale than broken"

### Real Scenarios

Use realistic domains, not toy examples:

| Good | Bad |
|------|-----|
| Order processing pipeline | "Process a list of numbers" |
| Email classification with confidence scoring | "Classify strings" |
| User registration with validation and notification | "Transform a struct" |
| Payment retry with circuit breaker | "Retry a function" |

### Variations

End with common modifications:

```markdown
### Variations

**Adding timeout per step:** Wrap individual processors with `pipz.NewTimeout`.

**Parallel enrichment:** Replace Sequence with Concurrent when enrichment
sources are independent.

**Dead letter queue:** Use Handle to route failed orders to a separate
pipeline instead of logging.
```

## Anti-Patterns

| Anti-pattern | Approach |
|-------------|----------|
| Recipe starts with package feature | Start with the scenario |
| Toy examples (numbers, strings) | Real-world domains |
| Code snippets that don't compile | Complete, runnable code |
| No explanation of decisions | Annotate the why, not the what |
| Recipe without output | Show what the reader should see |

## Checklist

- [ ] Each recipe starts with a concrete scenario
- [ ] Code is complete and compiles against current API
- [ ] Annotations explain decisions, not mechanics
- [ ] Scenarios use realistic domains
- [ ] Expected output documented
- [ ] Variations cover common modifications
- [ ] All frontmatter present (see `frontmatter.md`)
- [ ] Cross-references use numbered paths
