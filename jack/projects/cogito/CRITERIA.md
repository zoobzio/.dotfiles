# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- All primitives correctly implement `pipz.Chainable[*Thought]`
- Each reasoning primitive calls the correct zyn synapse type
- Notes stored with correct key, content, source, and metadata
- Provider resolution follows step → context → global order
- Thought.Clone() produces a correct deep copy for parallel processing
- Introspection generates meaningful summaries when enabled
- Converge correctly clones thoughts, runs branches in parallel, merges notes, and synthesizes

### What This Repo MUST NOT Contain

- LLM provider implementations
- Thought mutation during parallel processing (must use Clone)
- Direct zyn provider calls bypassing the synapse layer
- Persistent storage logic

## Review Priorities

1. Note correctness: each primitive must store results under the documented key with correct structure
2. Provider resolution: step override must take precedence over context and global
3. Clone safety: parallel primitives (Converge) must clone before dispatch — no shared mutation
4. Sift/Discern accuracy: semantic gate/router decisions must correctly control flow
5. Amplify termination: must respect max iterations and completion criteria
6. Session management: Reset/Truncate/Compress must not lose critical context

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Thought mutation during parallel Converge branches | Critical |
| Provider resolution order wrong | High |
| Primitive stores note under wrong key | High |
| Sift executes processor when decision is false | High |
| Amplify exceeds max iterations | High |
| Compress loses all session context | High |
| Introspection fails silently and blocks pipeline | Medium |
| Scan method returns wrong type | Medium |
| Capitan signal missing for step lifecycle | Medium |
| Missing test for a reasoning primitive | Medium |

## Standing Concerns

- Thought not safe for concurrent writes — verify all parallel paths use Clone()
- Discern route management is RWMutex-protected — verify no deadlock with nested processing
- Amplify loop with Transform + Binary can be expensive — verify timeout/circuit breaker compose correctly
- Compress replaces session content — verify summary quality doesn't degrade reasoning
- Note index uses sync.Map — verify no stale entries after Clone

## Out of Scope

- Thought not safe for concurrent writes is by design — Clone() for parallelism
- No persistence is intentional — Thought is in-memory reasoning context
- No chat interface — cogito is reasoning, chit is conversation
- Provider interface matches zyn.Provider — intentional coupling for synapse integration
