#!/bin/bash

echo -e "Starting inotifywait watcher script..."

# --- PHẦN WATCHER CHẠY NỀN ---
if [ "$AUTO_SEND_RESULT" = "1" ] || [ "$AUTO_SEND_RESULT" = "true" ]; then
    WATCH_DIR="/home/container/results/"
    API_URL="https://simcap.net/api/session/acc"
    echo -e "AUTO_SEND_RESULT is enabled. Watching directory: $WATCH_DIR"
    (
        inotifywait -m -e create --format "%f" "$WATCH_DIR" | while read NEWFILE &
        do
            FILEPATH="$WATCH_DIR/$NEWFILE"
            echo -e "New file detected: $FILEPATH. Sending to SimCap"
            curl -X POST "$API_URL" \
                -F "file=@${FILEPATH}" \
                -H "Content-Type: multipart/form-data"
            echo -e "File $FILEPATH sent to SimCap."
        done
    ) &
    echo -e "inotifywait watcher is running in background (PID $!)."
else
    echo -e "AUTO_SEND_RESULT is not enabled. Skipping watcher."
fi