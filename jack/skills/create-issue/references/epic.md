# Epic

An epic is a technical feature that groups stories and tasks. It is written in STE.

## Title

A short phrase that names the feature.

## Body

```markdown
## Goal

<one to three sentences>

## Stories

- [ ] #<story>
- [ ] #<story>

## Approach

<the technical shape of the implementation, one fact per sentence>

## Tasks

- [ ] #<task>
- [ ] #<task>

## Done when

- [ ] <one condition that is true when the epic is complete>
- [ ] <one condition that is true when the epic is complete>
```

- `## Stories` and `## Tasks` are task lists of linked issues. GitHub tracks their progress. Leave a list empty when no linked issue exists yet.
- `## Approach` states the technical design at the level the tasks are cut from.

## Example

Title:

```
Cache expiry
```

Body:

```markdown
## Goal

The cache enforces a maximum entry age. Processes with a steady write load run within a fixed memory budget.

## Stories

- [ ] #41

## Approach

Each entry stores its write time. A read compares the write time with the TTL and evicts an expired entry before it returns. A background sweep runs once per TTL interval and removes every expired entry. The TTL is a constructor option with no default.

## Tasks

- [ ] #42
- [ ] #43

## Done when

- [ ] Every story in this epic is closed.
- [ ] The benchmark in `bench/` shows bounded memory over one million writes with a TTL set.
```
