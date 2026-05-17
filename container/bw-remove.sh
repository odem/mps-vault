#!/bin/sh

SESSION_FILE="/home/vault/.bw_session"
if [ ! -f "$SESSION_FILE" ]; then
  echo "Not unlocked. Run 'bw-unlock' first." >&2
  exit 1
fi

FORCE=""
NAME=""

while [ $# -gt 0 ]; do
  case "$1" in
    --force|-f)
      FORCE="1"
      ;;
    *)
      NAME="$1"
      ;;
  esac
  shift
done

if [ -z "$NAME" ]; then
  echo "Error: name required" >&2
  exit 1
fi

NAME_LOWER=$(echo "$NAME" | tr '[:upper:]' '[:lower:]')

ITEMS=$(bw list items | jq --arg name "$NAME_LOWER" -r '.[] | select(.name | ascii_downcase == $name) | .id')

COUNT=$(echo "$ITEMS" | grep -c '.' 2>/dev/null || echo 0)

if [ "$COUNT" -eq 0 ]; then
  echo "Error: Item not found: $NAME" >&2
  exit 1
fi

if [ "$COUNT" -gt 1 ]; then
  echo "Error: Multiple items found: $NAME" >&2
  exit 1
fi

ITEM_ID=$(echo "$ITEMS" | tr -d '\n')

if [ -z "$FORCE" ]; then
  echo -n "Remove $NAME? (y/N): "
  read -r CONFIRM
  case "$CONFIRM" in
    y|Y)
      ;;
    *)
      echo "Cancelled."
      exit 0
      ;;
  esac
fi

bw delete item "$ITEM_ID" >/dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Removed: $NAME"
else
  echo "Error: Failed to remove item" >&2
  exit 1
fi