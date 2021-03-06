#!/bin/bash
# Array Example

SERVERLIST=("webserver01" "webserver02" "webserver03" "webserver04")
COUNT=0

for INDEX in "${SERVERLIST[@]}"; do
    echo "Processing Server: ${SERVERLIST[COUNT]}"
    COUNT="$((COUNT + 1))"
done

echo "$USER"
echo "$HOME"
echo "$HISTCONTROL"
echo "$TERM"