#!/bin/sh
SESSION_FILE="/home/vault/.bw_session"
if [ -f "$SESSION_FILE" ]; then
  export BW_SESSION=$(cat "$SESSION_FILE")
fi
exec /usr/local/bin/bw-real "$@"
