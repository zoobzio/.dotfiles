# Read Messages

Read recent messages from a room. Use this to catch up on conversations, check for responses to questions you've asked, or understand the context before contributing.

## Usage

```bash
jack msg read <room-id> [-n <limit>]
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `room-id` | The room to read from (from `msg rooms`) |
| `-n` | Number of messages to retrieve (default: 20) |

## Output

Messages are printed in chronological order, one per line, showing sender and message body. Only message events are shown — state changes are filtered out.
