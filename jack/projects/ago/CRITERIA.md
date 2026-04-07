# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Tool registration produces correct JSON Schema from Go types via sentinel
- Handler dispatch correctly deserializes JSON input into typed structs
- Input validation runs before handler execution — invalid input never reaches the handler
- ToolExecutor interface returns complete, correct tool definitions for LLM consumption
- ToolExecutor.Execute dispatches to the correct handler by name
- Middleware chain executes in order on every tool call without exception
- Tool errors serialize cleanly as tool results — no panics, no silent failures
- Capitan signals fire for every tool call with structured context (name, duration, error)

### What This Repo MUST NOT Contain

- LLM API calls or provider interaction
- Tool execution loop logic (call LLM, dispatch, loop)
- Conversation state management
- Business logic or domain-specific tool implementations
- Workflow orchestration, sagas, or compensation

## Review Priorities

1. Security boundary: unregistered tool names must be rejected, not silently ignored
2. Input validation: malformed JSON and failed validation must produce clear error results, not panics
3. Schema correctness: generated tool schemas must match the actual handler input types exactly
4. Context propagation: tenant ID, trace ID, session ID must flow to handlers via context
5. Middleware ordering: middleware must execute in registration order, wrapping the handler
6. Error isolation: a handler panic must be recovered and returned as a tool error result

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Unregistered tool name executes a handler | Critical |
| Handler receives input that failed validation | Critical |
| Tool schema doesn't match actual input type | Critical |
| Handler panic crashes the process instead of returning error | Critical |
| Context missing tenant ID when handler expects it | High |
| Middleware skipped for some tool calls | High |
| Tool error result loses error message or context | High |
| Schema generation fails silently (empty schema) | Medium |
| Capitan signal missing for failed tool call | Medium |
| Autodoc catalog incomplete or stale after registration | Low |

## Standing Concerns

- JSON Schema generation via sentinel must handle nested structs, slices, maps, pointers correctly
- Verify that concurrent tool calls (multiple Engage loops) don't race on shared registry state
- Verify that tool handler timeouts produce clean error results, not context deadline errors
- The ToolExecutor interface is cogito's contract — changes break cogito. Treat as stable API.

## Out of Scope

- Using zyn's tool definition types (not ago's own) is intentional — single source of truth
- No built-in tool handler implementations is intentional — application defines all handlers
- At-most-once execution per tool call is by design — the LLM retries by issuing a new call
