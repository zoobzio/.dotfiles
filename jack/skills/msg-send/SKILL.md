# Send Message

Send a message to a room. Communication is asynchronous — the other participants may not respond immediately. Be clear and specific in your messages so the conversation can progress without back-and-forth clarification.

## Usage

```bash
jack msg send <room-id> <message...>
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `room-id` | The room to send to (from `msg rooms`) |
| `message` | Your message (all remaining arguments are joined) |
