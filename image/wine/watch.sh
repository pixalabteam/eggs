#!/bin/bash

echo -e "Starting inotifywait watcher script..."

mkdir -p /home/container/results_bak
mv /home/container/results/* /home/container/results_bak/ 2>/dev/null

if [ "$AUTO_SEND_RESULT" = "1" ] || [ "$AUTO_SEND_RESULT" = "true" ]; then
    WATCH_DIR="/home/container/results"
    API_URL="https://sos.sumracing.vn/api/results/pre/import"
    API_KEY="${SUMRACING_API_KEY:-$X_SUMRACING_API_KEY}"
    echo -e "AUTO_SEND_RESULT is enabled. Watching directory: $WATCH_DIR"
    (
        inotifywait -m -e create --format "%f" "$WATCH_DIR" | while read NEWFILE
        do
            FILEPATH="$WATCH_DIR/$NEWFILE"
            echo -e "New file detected: $FILEPATH. Sending to SOS"
            
            if [ -f "$FILEPATH" ]; then
                FILE_CONTENT=$(iconv -f UTF-16LE -t UTF-8 "$FILEPATH" 2>/dev/null || cat "$FILEPATH")
                JSON_PAYLOAD="$FILE_CONTENT"
                
                curl -X POST "$API_URL" \
                    -H "Content-Type: application/json" \
                    -H "x-sumracing-api-key: $API_KEY" \
                    -d "$JSON_PAYLOAD"
                echo -e "File $FILEPATH content sent to SOS."
            else
                echo -e "File $FILEPATH not found or not readable."
            fi
        done
    ) &
    echo -e "inotifywait watcher is running in background (PID $!)."
else
    echo -e "AUTO_SEND_RESULT is not enabled. Skipping watcher."
fi