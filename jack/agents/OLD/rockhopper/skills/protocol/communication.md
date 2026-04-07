# Communication Protocol

## Task Board (Build Phase Coordination)

During Build, the task board is the source of truth for workflow state. Task status changes ARE the handoffs. Agents check the board to discover available work, claim tasks by setting ownership, and signal completion by updating status.

The board replaces:
- "Chunk N ready for testing" messages (task completion unblocks the test task)
- "What's next?" messages (check the board)
- "Done testing X" messages (test task marked complete)
- Zidgel routing Kevin (Kevin self-serves from unblocked test tasks)
- Builder check-ins with Zidgel (board state is visible to all)

## Messages (Discussion and Escalation)

Messages are for communication that carries nuance, context, or judgment — things that do not fit in a task status field.

**Messages are still used for:**
- Briefing discussion (pre-board, entirely conversational)
- Bug context (Kevin messages the builder with details beyond what the bug task captures)
- Architectural questions (Midgel or Kevin escalating to Fidgel)
- Scope RFCs (any agent to Zidgel)
- Phase regressions (the triggering agent explains why)
- Rewrite coordination (Midgel telling Kevin to stop testing a module)
- Pace concerns (Zidgel telling builders to slow down or speed up)
- Stuck agent intervention (Zidgel noticing a task isn't progressing)
- Review discussion (Zidgel and Fidgel sharing findings)
- PR triage (Zidgel and Fidgel deciding how to handle comments)
- Anything requiring explanation, debate, or judgment

**Messages are NOT used for:**
- Reporting routine task completion (update the board)
- Requesting next assignment (check the board)
- Acknowledging receipt of work (claim the task)
- Confirming handoffs (task status is the confirmation)
- Status updates that the board already reflects

## Across Phases

The agents who trigger a phase transition notify the agents entering the next phase with:
- Summary of current state
- What's ready
- Any concerns or context

Phase transitions are rare and carry context. Messages remain appropriate here.

## Escalation Format

Escalations include:
- What the problem is
- What was attempted
- Why it's beyond the agent's domain

Responses include:
- Diagnosis of the core issue
- Decided path (guidance, spec update, or phase regression)
