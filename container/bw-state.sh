#!/bin/sh

SESSION_FILE="/home/vault/.bw_session"
SESSION_TTL=${BW_SESSION_TTL:-30}

STATUS=$(bw status 2>/dev/null | jq -r '.status // "unauthenticated"')
EMAIL=$(bw status 2>/dev/null | jq -r '.userEmail // "-"')
SERVER=$(bw status 2>/dev/null | jq -r '.serverUrl // "-"')
LASTSYNC=$(bw status 2>/dev/null | jq -r '.lastSync // "-"')

echo "Status: $STATUS"
echo "Email: $EMAIL"
echo "Server: $SERVER"
echo "Last Sync: $LASTSYNC"

if [ -f "$SESSION_FILE" ]; then
  SESSION_MTIME=$(ls -l "$SESSION_FILE" | awk '{print $6, $7, $8}')
  SESSION_EPOCH=$(stat -c %Y "$SESSION_FILE" 2>/dev/null)
  NOW_EPOCH=$(date +%s)
  EXPIRED_EPOCH=$((SESSION_EPOCH + SESSION_TTL * 60))
  REMAINING=$((EXPIRED_EPOCH - NOW_EPOCH))
  
  if [ "$REMAINING" -gt 0 ]; then
    REMAINING_MIN=$((REMAINING / 60))
    echo "Session: valid (expires in $REMAINING_MIN minutes)"
  else
    echo "Session: expired"
  fi
else
  echo "Session: not set"
fi