---
name: architect
description: Design API systems — contracts, pipelines, events, capacitors, configuration, secrets
---

# Architect

Designing the architecture of an API. Each sub-file covers one architectural concern — read the one that matches what you are designing.

| Concern | File | When to Read |
|---------|------|-------------|
| Recon | `recon.md` | Before the briefing — survey the codebase and read memories |
| Contracts | `contracts.md` | Defining interfaces between handlers and implementations |
| Pipelines | `pipelines.md` | Designing composable data processing workflows with pipz |
| Events | `events.md` | Designing event signals with capitan |
| Capacitors | `capacitors.md` | Designing hot-reload runtime configuration with flux |
| Configuration | `config.md` | Designing static bootstrap configuration with fig |
| Secrets | `secrets.md` | Configuring secret providers for sensitive values |

Do not load all sub-files upfront. Read the specific sub-file when the current task requires designing that concern.
