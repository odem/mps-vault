#!/bin/sh

BW_REAL=/usr/local/bin/bw-real
SESSION_FILE="/home/vault/.bw_session"

if [ -f /run/secrets/bw_env ]; then
  . /run/secrets/bw_env
  export BW_CLIENTID BW_CLIENTSECRET BW_SERVER
fi

BW_SESSION_TTL=${BW_SESSION_TTL:-30}
BW_OUTPUT_FILE=${BW_OUTPUT_FILE:-/dev/shm/bw_last}

[ -n "$BW_SERVER" ] && $BW_REAL config server "$BW_SERVER"

if [ -n "$BW_CLIENTID" ] && [ -n "$BW_CLIENTSECRET" ]; then
  echo "Logging in with API key..."
  $BW_REAL login --apikey || echo "Login failed, continuing..."
fi

unset BW_CLIENTID BW_CLIENTSECRET SERVER

# Copy root's Bitwarden config to vault user (needed because bw runs as root but SSH users are vault)
if [ -d /root/.config ]; then
  cp -r /root/.config /home/vault/
  chown -R vault:vault /home/vault/.config
fi

# Copy session file if exists
if [ -f /root/.bw_session ]; then
  cp /root/.bw_session /home/vault/.bw_session
  chown vault:vault /home/vault/.bw_session
fi

if [ -n "$BW_SSH_PUBKEY" ]; then
  mkdir -p /home/vault/.ssh
  chown vault:vault /home/vault/.ssh
  chmod 700 /home/vault/.ssh
  echo "$BW_SSH_PUBKEY" >/home/vault/.ssh/authorized_keys
  chown vault:vault /home/vault/.ssh/authorized_keys
  chmod 600 /home/vault/.ssh/authorized_keys

  # Generate SSH host keys
  ssh-keygen -A 2>/dev/null || true

  # Run sshd as root
  /usr/sbin/sshd -D -p 22 &
fi

# Run cron as root
crontab -l >/dev/null 2>&1 || echo "* * * * * rm -f ${BW_OUTPUT_FILE:-/dev/shm/bw_last}
*/${BW_SESSION_TTL:-30} * * * * rm -f $SESSION_FILE && $BW_REAL lock" | crontab -
/usr/sbin/cron &

echo "Container ready. SSH on port 2222, or 'docker exec -it vault bw-unlock' to unlock."

# Use dumb-init to reap zombie processes
exec "$@"
