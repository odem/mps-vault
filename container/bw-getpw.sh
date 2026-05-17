#!/bin/sh

PW_FILE="/dev/shm/bw_last"
if [ -f "$PW_FILE" ]; then
  cat "$PW_FILE"
  rm -f "$PW_FILE"
else
  echo "No password file found" >&2
fi

exit 0