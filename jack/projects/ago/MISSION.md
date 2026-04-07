# Mission: ago

LLM tool execution framework — the bridge where reasoning becomes action.

## Purpose

ago is to LLM tool dispatch what rocco is to HTTP request handling. An LLM decides to call a tool by name with JSON arguments. ago validates the input, dispatches to a registered handler, enforces boundaries, and returns a typed result. The application author registers tools and handlers; ago handles validation, dispatch, middleware, schema generation, and observability.

ago exists because LLM tool execution requires typed handlers, input validation, security boundaries, audit trails, and schema generation for the LLM to see available tools — concerns that shouldn't be reimplemented per application.

## What This Package Contains

- Tool registration with name, description, parameter schema, and typed handler
- Handler pattern parallel to rocco endpoints: receive context + typed input, call contracts, return typed output
- Input deserialization from JSON into typed structs with validation via check
- Schema generation from registered tools for LLM consumption (tool definition format for Anthropic/OpenAI APIs)
- Middleware chain on tool execution: tenant injection, audit logging, rate limiting, observability
- ToolExecutor interface for cogito integration: `Tools()` returns available tool definitions, `Execute()` dispatches a call
- Autodocs: catalog of every registered tool with parameter schemas, descriptions, and metadata
- Capitan signals for tool lifecycle: called, succeeded, failed, duration

## What This Package Does NOT Contain

- LLM API interaction — that's zyn's job
- Tool execution loop (call LLM, dispatch tools, feed results, repeat) — that's cogito's Engage primitive
- Conversation state management — that's chit's job
- Business logic — the application registers handlers that call domain contracts

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `zyn` | Tool definition types (Tool schema, ToolCall) — ago uses zyn's types |
| `capitan` | Observability signals for tool lifecycle |
| `sentinel` | Type introspection for parameter schema generation |
| `check` | Input validation on tool parameters |

ago is consumed by:
- `cogito` — Engage primitive calls ago's ToolExecutor interface
- Applications defining domain-specific tool handlers (search, lookup, compute)

## Design Constraints

- The tool registry is the security boundary — only registered tools are callable by the LLM
- Tool handlers access services via sum.MustUse[Contract](ctx), same as rocco handlers
- Tenant ID, trace ID, session ID flow through context to tool handlers — never from LLM input
- Tool errors are not fatal to the system — they serialize as tool results and feed back to the LLM
- Tool definitions use zyn's types, not ago's own — single source of truth for the wire format

## Success Criteria

A developer can:
1. Register tools with typed handlers and have schemas generated automatically
2. Validate LLM tool call inputs with the same patterns used for HTTP request validation
3. Apply middleware (auth, audit, rate limiting) across all tool executions uniformly
4. Generate a catalog of all available tools for security review and documentation
5. Observe tool execution via capitan signals and aperture OTEL integration
6. Expose the tool registry to cogito via ToolExecutor without leaking registration or middleware internals

## Non-Goals

- Calling the LLM or managing the tool execution loop
- Managing conversation state or history
- Defining business logic for tool handlers
- Workflow orchestration or saga patterns
