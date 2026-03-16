# Fly

Git branch lifecycle for Midgel. Every flight has four phases: preflight, launch, rebase, land. Run the right subskill at the right time.

## When to Use

| Phase | When | Sub-File |
|-------|------|----------|
| Preflight | Before starting any build work | `preflight.md` |
| Launch | After preflight passes, before writing code | `launch.md` |
| Rebase | When main has moved ahead during build | `rebase.md` |
| Land | When build is complete and ready for PR | `land.md` |

## Rules

- Never commit directly to main. All work happens on a feature branch.
- Never start building without running preflight and launch first.
- Never hand off to Zidgel for PR without running land first.
