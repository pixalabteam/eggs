#!/bin/bash

echo -e "Starting inotifywait watcher script..."

BACKUP_DIR="/home/container/result_bak"

mkdir -p "$BACKUP_DIR"
mv /home/container/results/* "$BACKUP_DIR"/ 2>/dev/null

if [ "$AUTO_SEND_RESULT" = "1" ] || [ "$AUTO_SEND_RESULT" = "true" ]; then
    WATCH_DIR="/home/container/results"
    API_URL="${WEBHOOK_URL}"
    API_KEY="${WEBHOOK_API_KEY:-$X_WEBHOOK_API_KEY}"

    if [ -z "$API_URL" ]; then
        echo -e "WEBHOOK_URL is not set. Skipping watcher."
        exit 0
    fi

    echo -e "AUTO_SEND_RESULT is enabled. Watching directory: $WATCH_DIR"
    (
        inotifywait -m -e close_write --format "%f" "$WATCH_DIR" | while IFS= read -r NEWFILE
        do
            FILEPATH="$WATCH_DIR/$NEWFILE"
            echo -e "New file detected: $FILEPATH. Sending to SOS"
            
            if [ -f "$FILEPATH" ]; then
                FILE_CONTENT=$(iconv -f UTF-16LE -t UTF-8 "$FILEPATH" 2>/dev/null || cat "$FILEPATH")
                JSON_PAYLOAD="$FILE_CONTENT"
                
                CURL_EXIT=0
                HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "$API_URL" \
                    -H "Content-Type: application/json" \
                    -H "x-sumracing-api-key: $API_KEY" \
                    -d "$JSON_PAYLOAD") || CURL_EXIT=$?

                if [ "$CURL_EXIT" -eq 0 ] && [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
                    if mv "$FILEPATH" "$BACKUP_DIR"/; then
                        echo -e "File $FILEPATH uploaded successfully and moved to $BACKUP_DIR."
                    else
                        echo -e "Upload succeeded but failed to move $FILEPATH to $BACKUP_DIR."
                    fi
                else
                    echo -e "Failed to upload $FILEPATH (curl_exit=$CURL_EXIT, http_code=$HTTP_CODE). File kept in $WATCH_DIR for retry."
                fi
            else
                echo -e "File $FILEPATH not found or not readable."
            fi
        done
    ) &
    echo -e "inotifywait watcher is running in background (PID $!)."
else
    echo -e "AUTO_SEND_RESULT is not enabled. Skipping watcher."
fi