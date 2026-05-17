# AGENTS.md - Vault Project

Project-specific context for AI agents working on this codebase.

## Project Overview

A Docker container providing SSH access to a Bitwarden vault. Users SSH into the container, authenticate once, and can retrieve/add/remove passwords without installing the Bitwarden app.

## Architecture

```
┌─────────┐     SSH      ┌─────────────┐     HTTPS     ┌─────────────┐
│ Client  │ ───────────► │ Vault       │ ────────────► │ Bitwarden   │
└─────────┘              │ Container   │               │ Server      │
                         └─────────────┘               └─────────────┘
```

- **Base**: Debian bookworm-slim (pinned digest)
- **User**: vault (uid 1000)
- **Services**: SSH (port 22), Cron, Bitwarden CLI
- **Secrets**: Docker Compose secrets for API credentials

## File Structure

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Container orchestration |
| `container/Dockerfile` | Container image build |
| `container/entrypoint.sh` | Startup script (runs as root) |
| `container/bw-*.sh` | Vault management scripts |
| `env/.env-example` | Template for environment variables |
| `installer/install.sh` | Kitty plugin and SSH setup |

## Commands

All scripts are in `/usr/local/bin/` inside the container:

| Script | Params | Description |
|--------|--------|-------------|
| `bw-unlock` | - | Unlock vault with master password |
| `bw-state` | - | Show session status (locked/unlocked, TTL) |
| `bw-list` | `<name>` | List items; `<name>` for details |
| `bw-fzf` | - | Interactive search with fzf |
| `bw-getpw` | - | Print password, delete file |
| `bw-add` | `<name> <user> <pass> [folder] [url]` | Add new item |
| `bw-remove` | `<name> [--force]` | Remove item |

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SSH_PORT` | Host port (empty = no binding) | No |
| `BW_SERVER` | Bitwarden server URL | Yes |
| `BW_CLIENTID` | API key client ID | Yes |
| `BW_CLIENTSECRET` | API key client secret | Yes |
| `BW_SESSION_TTL` | Auto-lock minutes | No (default: 30) |
| `BW_SSH_PUBKEY` | SSH authorized key | Yes |

## Security

### Implemented
- Passwords in `/dev/shm` (tmpfs/RAM), never persisted to disk
- Docker secrets hide credentials from `docker inspect`
- Sessions expire after `BW_SESSION_TTL` minutes
- Password file deleted immediately after retrieval
- Vault data fetched into container, never leaves (only password transmitted)
- SSH key-based authentication only

### Limitations
- Container runs as root (required for SSH, cron)
- No AppArmor/SELinux profiles
- No fail2ban or rate limiting
- Single SSH key, no MFA on SSH

## Development

### Build
```bash
docker compose build
```

### Run
```bash
docker compose up -d
```

### Logs
```bash
docker compose logs vault
```

### Restart
```bash
docker compose restart
```

## Testing Workflow

1. **Start container**: `docker compose up -d`
2. **Unlock vault**: SSH in, run `bw-unlock`, enter master password
3. **Test commands**:
   - `bw-list` - should show items
   - `bw-add TestUser test@test.com pass123` - add test item
   - `bw-list TestUser` - verify item exists
   - `bw-remove TestUser --force` - remove test item

### Manual Test Commands (via SSH)
```bash
ssh vault -p 7777 "bw-state"
ssh vault -p 7777 "bw-list"
ssh vault -p 7777 "bw-add Test t@t.com pwd"
ssh vault -p 7777 "bw-remove Test --force"
```

## Known Issues

- Folder creation in `bw-add` may have issues with special characters
- SSH argument passing requires `sh -c` for commands with arguments
- Session expires after 30 minutes (cron job)

## Repo

https://github.com/odem/mps-vault