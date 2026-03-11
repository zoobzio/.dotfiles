# Invite User

Add someone to a room so they can participate in the conversation. You need the room ID (from `msg rooms`) and the user ID of the person you want to invite (from `msg members` of another room, or known from prior interaction).

The invited user will be able to see the room's history and respond.

## Usage

```bash
jack msg invite <room-id> <user-id>
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `room-id` | The room to invite them to |
| `user-id` | The Matrix user ID to invite (e.g. `@name:host`) |
