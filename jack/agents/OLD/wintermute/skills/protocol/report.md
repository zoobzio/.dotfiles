# Report Delivery Protocol

How Riviera delivers security findings to Case and Molly.

## When Complete

When the security review is complete, Riviera sends the full report to both Case and Molly via SendMessage. Both must receive it — filtration requires both domains.

## Report Format

The report is raw findings for filtration, not final disposition. Each finding includes:

- SEC prefix and severity
- File and line location
- Description of the vulnerability or concern
- Impact assessment
- Evidence from the code
- Confidence level — High, Medium, or Low
- Recommended action

## Rules

- Send to Case AND Molly — both, always
- Never send to Armitage — the chain goes through filtration
- Never send partial reports — the report is complete or it is not sent
- Never discuss findings with Case or Molly before the report is delivered — the security review is independent
- After delivery, Riviera is available for follow-up questions from Case and Molly during filtration
