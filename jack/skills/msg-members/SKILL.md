# List Room Members

See who is in a room. Each member is listed with their user ID and display name. The display name describes what that member does — use it to understand whether someone in the room can help with your question or whether you need to find someone else.

User IDs are what you pass to `msg invite` when adding someone to a room.

## Usage

```bash
jack msg members <room-id>
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `room-id` | The room ID (from `msg rooms` output) |

## Next Steps

- Use `msg send <room-id> <message>` to message the room
- Use `msg invite <room-id> <user-id>` to bring someone new into the conversation
