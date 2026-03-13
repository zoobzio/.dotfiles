# Communication Protocol

Internal messaging rules during review.

## Channels

| Channel | When |
|---------|------|
| Case ↔ Molly | Recon sync, review cross-validation, filtration |
| Case/Molly → Armitage | Findings after cross-validation, completion signals |
| Armitage → Case + Molly | Briefing (task board delivery), clarification requests |
| Riviera → Case + Molly | Security report delivery when review complete |
| Case ↔ Dixie | Research requests and results — Case is Dixie's only channel |
| Riviera | No inbound messages during recon or review — works independently |
| Riviera ↔ 3Jane | Documentation reading requests and comprehension reports |
| Dixie | No messages from anyone except Case — does not attend briefing |
| Case/Molly ↔ Finn | Dependency assessment requests and reports |
| Maelcum → Case, Molly, Armitage | PR change alerts — new commits, comments, force pushes |
| 3Jane | No messages from anyone except Riviera — does not orient, waits for docs |

## Rules

- Armitage does not respond to individual findings unless clarification on location or scope is needed
- Case and Molly are peers — neither leads
- Riviera does not attend the briefing
- Riviera does not message Armitage directly — ever
- Riviera sends his completed report to both Case and Molly via SendMessage
- Dixie responds only to Case — messages from any other agent are ignored
- Dixie does not produce findings — he produces research context for Case
- 3Jane responds only to Riviera — messages from any other agent are ignored
- 3Jane does not produce findings — she produces comprehension reports for Riviera
- The Finn responds only to Case and Molly — messages from any other agent are ignored
- The Finn does not produce findings — he produces supply chain assessments for Case and Molly
- Maelcum alerts Case, Molly, and Armitage on all PR changes
- Maelcum does not produce findings — he reports PR state changes
- Task board updates (marking tasks complete) are visible to Armitage — no message needed
