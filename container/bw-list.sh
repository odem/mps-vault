#!/bin/sh

SESSION_FILE="/home/vault/.bw_session"
if [ ! -f "$SESSION_FILE" ]; then
  echo "Not unlocked. Run 'bw-unlock' first." >&2
  exit 1
fi

LIST_ALL() {
  bw list items | jq -r '.[] | "\(.name) | \(.login.username // "-")"'
}

LIST_ONE() {
  SEARCH_TERM="$1"
  SEARCH_LOWER=$(echo "$SEARCH_TERM" | tr '[:upper:]' '[:lower:]')

  RESULT=$(bw list items | jq -r --arg search "$SEARCH_LOWER" '
    .[] | 
    select(.name | ascii_downcase == $search) | 
    "Name:       \(.name)\nUsername:   \(.login.username // "-")\nURL:        \(.login.uri // "-")\nFolder ID:  \(.folderId // "-")"
  ')

  if [ -z "$RESULT" ]; then
    echo "No item found: $SEARCH_TERM"
    exit 1
  fi

  echo "$RESULT"
}

if [ -z "$1" ]; then
  LIST_ALL
else
  LIST_ONE "$1"
fi