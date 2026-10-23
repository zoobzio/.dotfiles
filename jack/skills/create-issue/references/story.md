# Story

A story is a problem or request from the user's perspective. The story and its use cases are written in the user's voice. The acceptance criteria are written in STE. Technical detail belongs in the tasks that resolve the story.

## Title

A short phrase in the user's words.

## Body

```markdown
## Story

As a <user>, I want <capability> so that <outcome>.

## Use cases

- <one concrete scenario or example in the user's words>
- <one concrete scenario or example in the user's words>

## Acceptance criteria

- [ ] <one condition that is true for the user when the story is done>
- [ ] <one condition that is true for the user when the story is done>

## Open questions

- <one question and who answers it>

Part of #<epic>
```

- Include `## Open questions` only when a question remains. Omit the section otherwise.
- Add `Part of #<epic>` as the last line when the story belongs to an epic. Omit the line otherwise.

## Example

Title:

```
Keep the cache from growing forever
```

Body:

```markdown
## Story

As an operator of a long-running service, I want old cache entries to expire so that the process stays within its memory budget.

## Use cases

- My service runs for weeks. Today I restart it every few days because memory climbs until the host swaps.
- I want to set a maximum age once, in config, and trust that nothing older stays in memory.

## Acceptance criteria

- [ ] The operator sets a maximum entry age in configuration.
- [ ] Memory use stays bounded over a seven-day run with a steady write load.

## Open questions

- Which default age applies when the operator sets none? Product decides.

Part of #40
```
