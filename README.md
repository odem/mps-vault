# Vault

A Docker container that provides SSH access to your Bitwarden vault. Use it to fetch passwords from anywhere on your network without installing the Bitwarden app.

## Use Case

You have a central server (home server, NAS, Raspberry Pi) running this container. From any machine on your network - laptop, phone via Termux, another desktop - you SSH into the container, unlock your vault once, and grab passwords.

```
┌─────────┐     SSH      ┌─────────────┐     HTTPS     ┌─────────────┐
│ Laptop  │ ───────────► │ Vault       │ ────────────► │ Bitwarden   │
│ Phone   │              │ Container   │               │ Server      │
└─────────┘              └─────────────┘               └─────────────┘
```

## What You Get

- **SSH access** to your Bitwarden vault via CLI
- **Interactive search** with fzf - fuzzy find your passwords
- **Session persistence** - unlock once, stays unlocked for 30 min
- **Password retrieval** - single command outputs password to file and deletes it on retrieval

## Quick Start

### 1. Get API Credentials

1. Go to [bitwarden.com](https://bitwarden.com) → Your vault → Settings → Security → Security Keys
2. Create an API key (client_id + client_secret)

### 2. Configure

```bash
cp env/.env-example env/.env
```

Edit `env/.env`:
```
BW_SERVER=https://vault.bitwarden.eu      # or your self-hosted URL
BW_CLIENTID=your_client_id
BW_CLIENTSECRET=your_client_secret
BW_SSH_PUBKEY=ssh-rsa AAAA...             # your public key
```

### 3. Run

```bash
docker compose up -d
```

> **Tip:** Set `SSH_PORT=` (empty) in `.env` to skip host binding. Access via `docker exec` instead of SSH.

### 4. Use

```bash
# Connect (port from SSH_PORT in .env, default 7777)
ssh vault@<server-ip> -p ${SSH_PORT:-7777}

# Inside the container:
bw-unlock     # enter master password (one time)
bw-fzf        # search and select password
bw-getpw      # print password, then delete it immediately
```

## Examples

### Get a password in one line (from your local machine)

```bash
ssh vault@192.168.1.100 -p ${SSH_PORT:-7777} "bw-fzf && bw-getpw"
```

### Use with a password manager integration

The installer sets up a Kitty plugin. If you use Kitty terminal:

```bash
# Press Ctrl+B in Kitty while in a password field
# Select password via fzf
# Password auto-typed into the field
```

### List all logins

```bash
ssh vault@YOUR_IP -p ${SSH_PORT:-7777} bw-list
```

## Available Commands

| Command | Description |
|---------|-------------|
| `bw-unlock` | Unlock vault with master password |
| `bw-fzf` | Interactive search, saves to `/dev/shm/bw_last` |
| `bw-getpw` | Print password from file, then delete file |
| `bw-list` | List all vault items |
| `bw` | Direct Bitwarden CLI access |

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `SSH_PORT` | SSH port on host (leave empty to skip host binding) | 7777 |
| `BW_SERVER` | Bitwarden server URL | Required |
| `BW_CLIENTID` | API client ID | Required |
| `BW_CLIENTSECRET` | API client secret | Required |
| `BW_SESSION_TTL` | Minutes before auto-lock | 30 |
| `BW_SSH_PUBKEY` | SSH public key for access | Required |

## Security

- Passwords stored in `/dev/shm` (RAM), never written to disk
- Docker secrets hide credentials from `docker inspect`
- Sessions auto-expire after 30 minutes
- Password file deleted immediately after retrieval
- SSH key + master password required (same as desktop app)
- **Data isolation**: All vault items are fetched into the container but never leave it. Only the final selected password is transmitted to the client.

## Troubleshooting

```bash
# Check if container is running
docker ps | grep vault

# View logs
docker compose logs vault

# Restart
docker compose restart
```

## License

MIT - free and open source, no warranties.
