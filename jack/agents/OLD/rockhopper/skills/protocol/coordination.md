# Coordination Protocol

## Direct Handoffs (Outside Build)

Outside Build, the direct handoff protocol applies:

1. Sender messages: "Module X is ready for you"
2. Receiver confirms: "Picked up module X"
3. Sender proceeds to next work

No silent handoffs. No fire-and-forget. If the receiver doesn't confirm, the sender follows up.

## Coordination During Rewrites

When Midgel needs to rewrite code that Kevin is actively testing:

1. Midgel messages Kevin: "I need to rewrite module X. Stop testing it."
2. Kevin confirms he has stopped
3. Midgel rewrites
4. Midgel messages Kevin: "Module X rewritten and ready"
5. Kevin confirms and resumes
