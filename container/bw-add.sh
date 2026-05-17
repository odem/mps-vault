#!/bin/sh

SESSION_FILE="/home/vault/.bw_session"
if [ ! -f "$SESSION_FILE" ]; then
  echo "Not unlocked. Run 'bw-unlock' first." >&2
  exit 1
fi

NAME="$1"
USERNAME="$2"
PASSWORD="$3"
FOLDER="$4"
URL="$5"
NOTES="$6"

if [ -z "$NAME" ]; then
  echo "Error: name required" >&2
  exit 1
fi

if [ -z "$PASSWORD" ]; then
  echo "Error: password required" >&2
  exit 1
fi

if [ -n "$FOLDER" ] && echo "$FOLDER" | grep -q ' '; then
  echo "Error: folder name cannot contain spaces" >&2
  exit 1
fi

EXISTS=$(bw list items | jq -r --arg name "$NAME" '.[] | select(.name == $name) | .id')
if [ -n "$EXISTS" ]; then
  echo "Error: Item already exists: $NAME" >&2
  exit 1
fi

FOLDER_ID="null"
if [ -n "$FOLDER" ]; then
  FOLDER_ID=$(bw list folders | jq -r --arg name "$FOLDER" '.[] | select(.name == $name) | .id')
  if [ "$FOLDER_ID" = "null" ] || [ -z "$FOLDER_ID" ]; then
    FOLDER_NAME_B64=$(echo -n "$FOLDER" | base64)
    FOLDER_RESULT=$(bw create folder "$FOLDER_NAME_B64" 2>/dev/null)
    FOLDER_ID=$(echo "$FOLDER_RESULT" | jq -r '.id')
  fi
fi

URI_JSON="[]"
if [ -n "$URL" ]; then
  URI_JSON="[{\"uri\":\"$URL\",\"match\":null}]"
fi

NOTES_JSON="null"
if [ -n "$NOTES" ]; then
  NOTES_JSON="\"$NOTES\""
fi

JSON="{"
JSON="${JSON}\"name\":\"$NAME\","
JSON="${JSON}\"type\":1,"
JSON="${JSON}\"reprompt\":0,"
JSON="${JSON}\"login\":{"
JSON="${JSON}\"username\":\"$USERNAME\","
JSON="${JSON}\"password\":\"$PASSWORD\","
JSON="${JSON}\"uris\":$URI_JSON"
JSON="${JSON}},"
JSON="${JSON}\"notes\":$NOTES_JSON,"
JSON="${JSON}\"folderId\":$FOLDER_ID,"
JSON="${JSON}\"favorite\":false"
JSON="${JSON}}"

JSON_B64=$(echo -n "$JSON" | base64)

RESULT=$(bw create item "$JSON_B64" 2>/dev/null)

if echo "$RESULT" | jq -e '.id' >/dev/null 2>&1; then
  if [ -n "$FOLDER" ]; then
    echo "Added: $NAME (folder: $FOLDER)"
  else
    echo "Added: $NAME"
  fi
else
  echo "Error: Failed to create item" >&2
  echo "$RESULT" >&2
  exit 1
fi