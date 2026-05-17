#!/bin/sh
if [ -f /run/secrets/bw_env ]; then
  . /run/secrets/bw_env
fi

OUTPUT=${BW_OUTPUT_FILE:-/dev/shm/bw_last}
SESSION_FILE="/home/vault/.bw_session"

if [ ! -f "$SESSION_FILE" ]; then
  bw-unlock
fi

bw list items | jq -r '.[] | "\(.name) \(.login.username) \(.login.password)"' |
  fzf --delimiter=' ' --with-nth=1,2 --nth=1,2 |
  awk '{ print $3 }' > "$OUTPUT"
