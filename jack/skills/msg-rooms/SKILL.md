# List Rooms

See all rooms you are part of. This is your starting point for understanding what conversations exist and where to participate. Each room has a name and optionally a topic that describes its purpose.

Use this to orient yourself before sending messages — check what rooms are available, what they're about, and whether the conversation you need already exists before creating a new one.

## Usage

```bash
jack msg rooms
```

## Output

Each room is listed with its ID, name, and topic. The room ID is what you pass to other `msg` commands (`send`, `read`, `members`, `invite`).

## Next Steps

- Use `msg members <room-id>` to see who is in a room
- Use `msg read <room-id>` to catch up on a conversation
- If no existing room fits your need, use `msg create` to start a new one
