# Vault

SSH access to your Bitwarden vault. No app install needed.

```
┌─────────┐     SSH      ┌─────────────┐     HTTPS     ┌─────────────┐
│ Laptop  │ ───────────► │ Vault       │ ────────────► │ Bitwarden   │
│ Phone   │              │ Container   │               │ Server      │
└─────────┘              └─────────────┘               └─────────────┘
```

## Quick Start

1. Get API key: Bitwarden → Settings → Security → Security Keys → New API Key
2. `cp env/.env-example env/.env` → edit with your values
3. `docker compose up -d`
4. `ssh vault -p 7777` → `bw-unlock` (enter master password) → `bw-fzf` (choose) → `bw-getpw` (get password)

## Commands

| Command | Alias | Params | Description |
|---------|-------|--------|-------------|
| `bw-unlock` | `bvu` | - | Unlock vault (enter master password) |
| `bw-state` | `bvs` | - | Show session status |
| `bw-list` | `bvl` | `<name>` | List all items |
| `bw-fzf` | `bvc` | - | Interactive search (fzf) |
| `bw-getpw` | `bvg` | - | Get last selected password |
| `bw-add` | `bva` | `<name> <user> <pass> [folder] [url]` | Add item |
| `bw-remove` | `bvr` | `<name> [--force]` | Remove item |

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `SSH_PORT` | Host port (empty = no binding) | 7777 |
| `BW_SERVER` | Bitwarden server URL | - |
| `BW_CLIENTID` | API client ID | - |
| `BW_CLIENTSECRET` | API client secret | - |
| `BW_SESSION_TTL` | Minutes before auto-lock | 30 |
| `BW_SSH_PUBKEY` | SSH public key | - |

## Security

- Passwords in `/dev/shm` (RAM), never written to disk
- Docker secrets hide credentials from `docker inspect`
- Sessions auto-expire after 30 minutes
- Password file deleted immediately after retrieval
- Vault data stays in container; only password transmitted to client
- SSH key + master password required (same as desktop app)

## SSH Config

```ssh
Host vault
    HostName localhost
    User vault
    Port 7777
    IdentityFile ~/.ssh/id_rsa
```

## Aliases

```bash
alias bvs='ssh vault bw-state'
alias bva='ssh vault bw-add'
alias bvr='ssh vault bw-remove'
alias bvl='ssh vault bw-list'
alias bvc='ssh vault bw-fzf'
alias bvg='ssh vault bw-getpw'
alias bvu='ssh vault bw-unlock'
```

## Environment

```
SSH_PORT=7777
BW_SERVER=https://vault.bitwarden.eu
BW_CLIENTID=your_client_id
BW_CLIENTSECRET=your_client_secret
BW_SESSION_TTL=30
BW_OUTPUT_FILE=/dev/shm/bw_last
BW_SSH_PUBKEY=ssh-rsa AAAA...
```

## License

MIT - free, open source, no warranties.