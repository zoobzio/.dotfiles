# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Provider interface correctly abstracts all embedding APIs
- Service correctly handles chunking→embedding→pooling→normalization pipeline
- QueryProviderFactory detection and query/document distinction work correctly
- All vector operations (cosine, dot product, euclidean) produce mathematically correct results
- Reliability options compose correctly via pipz
- Provider implementations produce correct API calls and parse responses

### What This Repo MUST NOT Contain

- Vector storage or search
- Model training or fine-tuning
- Token counting

## Review Priorities

1. Vector math correctness: similarity/distance calculations must be mathematically correct
2. Provider correctness: API calls must match provider specifications exactly
3. Chunking reliability: no text lost or duplicated during chunk→embed→pool
4. Query/document distinction: must use correct provider mode
5. Normalization: L2 normalization must produce unit vectors
6. Reliability composition: pipz options must not interfere with embedding flow

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Vector math produces wrong result | Critical |
| Provider API call malformed | Critical |
| Text lost during chunking | High |
| Wrong provider mode (query vs document) | High |
| Normalization produces non-unit vector | High |
| Dimensions mismatch between provider and response | Medium |
| Chunking strategy edge case (empty chunks) | Medium |

## Standing Concerns

- Chunker sentence splitting on `.!?` is simple — verify no false splits in abbreviations
- Pooling mode affects vector quality — verify mean pooling handles variable chunk counts
- Provider rate limits vary — verify rate limiter configuration is per-provider
- Fallback provider may have different dimensions — verify dimension mismatch is caught

## Out of Scope

- No vector storage is intentional — vex generates, storage is separate
- Provider implementations in submodules is intentional — import only what you need
- Default L2 normalization is intentional — most similarity searches expect unit vectors
