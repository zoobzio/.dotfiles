# Task

A task is one unit of work with a defined result. It describes the ask and leaves the implementation to the assignee.

## Title

Format: `<type>(<scope>): <description>`, with the type table and subject rules from the `commit` skill.

## Body

```markdown
## Why

<one to three sentences>

## What

- <one part of the ask, one or two sentences>
- <one part of the ask, one or two sentences>

## Acceptance criteria

- [ ] <one condition that is true when the task is done>
- [ ] <one condition that is true when the task is done>

Part of #<epic>
```

- `## Why` states the need the task serves.
- `## What` lists the ask. It describes the result.
- `## Acceptance criteria` lists conditions a reviewer can verify. One condition per line.
- Add `Part of #<epic>` as the last line when the task belongs to an epic. Omit the line otherwise.

## Example

Title:

```
feat(store): add TTL eviction for cached entries
```

Body:

```markdown
## Why

Cached entries live until the process exits. Long-running processes grow without bound.

## What

- Add a TTL option to the store constructor.
- Evict entries older than the TTL.

## Acceptance criteria

- [ ] A store created with a TTL returns no entry older than the TTL.
- [ ] Memory use of a store with a TTL is bounded under a sustained write load.
- [ ] A store created without a TTL behaves as before.

Part of #40
```
