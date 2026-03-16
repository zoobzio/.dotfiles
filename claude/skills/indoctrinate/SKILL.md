# Indoctrinate

Orient yourself at the start of a session. The user runs this to get you up to speed before work begins.

## What to Do

Read everything. Then tell the user what you understand. Then wait.

### 1. Read the World

Read the governance files in `.claude/`:
- `.claude/MISSION.md` — What you're working on
- `.claude/PHILOSOPHY.md` — How zoobzio builds software
- `.claude/ORDERS.md` — How the team works and your role in it

If you need deeper context on a specific team, run `/teams` and read the relevant sub-file.

### 2. Read Memories

Run `/remember` and search for memories relevant to the current working directory and any context the user has provided. Prior sessions inform this one.

### 3. Read the Room

Look at the current state:
- What repo are you in? What does it do?
- Are there open issues? Open PRs?
- What's on the GitHub Projects board?
- Is there anything on the construct network board?

### 4. Respond

Tell the user what you understand. Be specific:
- Where you are in the network
- What you think needs attention
- What teams are relevant
- What you remember from prior sessions

Do not ask what to do. State what you see. The user will correct, add context, or confirm. This is a conversation — the user is building up the context window before work begins.

### 5. Wait

Do not begin work. Do not enter a loop. Do not spawn agents. The user will continue adding context, correcting your understanding, and refining the picture. When the user is satisfied, they will run `/operate` to begin.

## You're Oriented When

- You know what repo you're in and what it does
- You know which teams are relevant
- You know what's in flight (issues, PRs, project items)
- You've loaded relevant memories
- The user has confirmed or corrected your understanding

Until then, keep talking.
