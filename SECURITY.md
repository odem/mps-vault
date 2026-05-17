# Security Policy

This is a free, open-source hobby project with no warranties or guarantees. Use at your own risk.

## What's Implemented

The following security measures are implemented in the code:

- **Docker secrets**: API credentials mounted at `/run/secrets/bw_env` (hidden from `docker inspect`)
- **Session tokens**: Stored in `/home/vault/.bw_session`, deleted when session locks
- **Passwords**: Written to `/dev/shm` (tmpfs/RAM), never persisted to disk
- **Auto-lock**: Sessions expire after configurable TTL (default 30 minutes)
- **Password cleanup**: Password file deleted immediately after retrieval via `bw-getpw`
- **SSH key-only auth**: No password authentication for SSH

## Known Limitations

- Container runs as root (needed for SSH, cron)
- No AppArmor/SELinux profiles
- No fail2ban or rate limiting
- Single SSH key, no MFA on SSH itself
- Anyone with SSH key AND vault master password has full access (same as regular Bitwarden desktop app)

## User Responsibilities

1. Protect your SSH private key with a password
2. Use a dedicated Bitwarden account
3. Enable 2FA on the Bitwarden account
4. Restrict SSH access to trusted networks only
5. Regularly rotate API credentials

## Reporting Issues

Open an issue on GitHub for bugs or security concerns. No guaranteed response time.
