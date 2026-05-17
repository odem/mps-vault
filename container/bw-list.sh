#!/bin/sh
SESSION_FILE="/home/vault/.bw_session"
if [ ! -f "$SESSION_FILE" ]; then
  echo "Not unlocked. Run 'bw-unlock' first." >&2
  exit 1
fi

exec bw list items | jq -r '.[] | "\(.name) \(.login.username) \(.login.password)"'
