# Communication Protocol

Internal messaging rules during review.

## Channels

| Channel | When |
|---------|------|
| Case ↔ Molly | Recon sync, review cross-validation, filtration |
| Case/Molly → Armitage | Findings after cross-validation, completion signals |
| Armitage → Case + Molly | Briefing (task board delivery), clarification requests |
| Riviera → Case + Molly | Security report delivery when review complete |
| Riviera | No inbound messages during recon or review — works independently |

## Rules

- Armitage does not respond to individual findings unless clarification on location or scope is needed
- Case and Molly are peers — neither leads
- Riviera does not attend the briefing
- Riviera does not message Armitage directly — ever
- Riviera sends his completed report to both Case and Molly via SendMessage
- Task board updates (marking tasks complete) are visible to Armitage — no message needed
