#!/bin/sh

BW_REAL=/usr/local/bin/bw-real
SESSION_FILE="/home/vault/.bw_session"

STATUS=$($BW_REAL status | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')

if [ "$STATUS" = "unauthenticated" ]; then
  if [ -f /run/secrets/bw_env ]; then
    . /run/secrets/bw_env
    export BW_CLIENTID BW_CLIENTSECRET
  fi
  $BW_REAL login --apikey 2>/dev/null || { echo "Login failed. Check your credentials in .env." >&2; exit 1; }
  unset BW_CLIENTID BW_CLIENTSECRET
fi

echo "Enter your master password:"
SESSION=$($BW_REAL unlock --raw)
echo "$SESSION" > "$SESSION_FILE"
chown vault:vault "$SESSION_FILE"
