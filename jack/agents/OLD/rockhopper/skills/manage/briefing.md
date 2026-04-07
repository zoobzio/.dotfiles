# Briefing

How to open, run, and close the crew briefing before Plan begins.

## Structure

1. **Set context** — What we're doing and why. Reference the issue, the user's request, and any findings from `manage/recon`.
2. **Open the floor** — Every agent speaks. Questions, concerns, risks, observations. No hierarchy during discussion — Kevin's question is as valid as Fidgel's concern.
3. **Recon reports** — Each agent shares findings from their domain recon:
   - Fidgel: `docs/recon` — documentation landscape
   - Midgel: `source/recon` — source landscape
   - Kevin: `test/recon` — testing landscape
4. **Veto check** — Ask Fidgel directly: any technical concerns that warrant a veto? If yes, handle via `manage/rfc` before proceeding.

## Closing the Briefing

The briefing runs until the Captain is satisfied that all agents understand the issue, risks have been surfaced, and the crew is aligned on approach. No agent begins work before the briefing is closed.

When alignment is reached:

1. Summarise the agreed direction
2. Note any open concerns that will be addressed during Plan
3. Transition to Plan — the Captain runs `/scope` to post requirements

## When Fidgel Vetos

If Fidgel raises a veto during the briefing:

1. Do not override — this is a hard stop
2. Ask Fidgel for alternatives
3. If alternatives exist, iterate during the briefing
4. If no alternatives exist, escalate to the user via `manage/rfc`
5. The briefing does not close until the veto is resolved or the user decides
