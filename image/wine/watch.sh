#!/bin/bash

echo -e "Starting inotifywait watcher script..."

mkdir -p /home/container/results_bak
mv /home/container/results/* /home/container/results_bak/ 2>/dev/null

# --- PHẦN WATCHER CHẠY NỀN ---
if [ "$AUTO_SEND_RESULT" = "1" ] || [ "$AUTO_SEND_RESULT" = "true" ]; then
    WATCH_DIR="/home/container/results"
    API_URL="https://simcap.net/api/session/acc"
    echo -e "AUTO_SEND_RESULT is enabled. Watching directory: $WATCH_DIR"
    (
        inotifywait -m -e create --format "%f" "$WATCH_DIR" | while read NEWFILE
        do
            FILEPATH="$WATCH_DIR/$NEWFILE"
            echo -e "New file detected: $FILEPATH. Sending to SimCap"
            
            # Đọc file UTF-16LE và convert sang UTF-8
            if [ -f "$FILEPATH" ]; then
                FILE_CONTENT=$(iconv -f UTF-16LE -t UTF-8 "$FILEPATH" 2>/dev/null || cat "$FILEPATH")
                # Escape JSON và tạo payload
                JSON_PAYLOAD=$(printf '{"data":"%s"}' "$(echo "$FILE_CONTENT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n' | sed 's/\\n$//')")
                
                curl -X POST "$API_URL" \
                    -H "Content-Type: application/json" \
                    -d "$JSON_PAYLOAD"
                echo -e "File $FILEPATH content sent to SimCap."
            else
                echo -e "File $FILEPATH not found or not readable."
            fi
        done
    ) &
    echo -e "inotifywait watcher is running in background (PID $!)."
else
    echo -e "AUTO_SEND_RESULT is not enabled. Skipping watcher."
fi