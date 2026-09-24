#!/bin/bash

echo "Starting result watcher script..."

WATCH_DIR="/home/container/results"
BACKUP_DIR="/home/container/result_bak"
API_URL="${WEBHOOK_URL}"
API_KEY="${WEBHOOK_API_KEY:-$X_WEBHOOK_API_KEY}"
UPLOAD_RETRIES="${UPLOAD_RETRIES:-5}"
RETRY_DELAY="${UPLOAD_RETRY_DELAY:-5}"
UPLOAD_INTERVAL="${UPLOAD_INTERVAL:-1}"
UPLOAD_LOCK_FILE="${TMPDIR:-/tmp}/result-upload.lock"

if [ "$AUTO_SEND_RESULT" != "1" ] && [ "$AUTO_SEND_RESULT" != "true" ]; then
    echo "AUTO_SEND_RESULT is not enabled. Skipping watcher."
    exit 0
fi

if [ -z "$API_URL" ]; then
    echo "WEBHOOK_URL is not set. Skipping watcher."
    exit 0
fi

mkdir -p "$WATCH_DIR" "$BACKUP_DIR"

upload_file() {
    local filepath="$1"
    local lockfile="${filepath}.uploading"
    local payload
    local curl_exit
    local http_code
    local lock_fd

    [ -f "$filepath" ] || return 0

    # mkdir is an atomic per-file lock, so startup scans and inotify cannot upload twice.
    mkdir "$lockfile" 2>/dev/null || return 0

    payload=$(mktemp "${TMPDIR:-/tmp}/result-upload.XXXXXX") || {
        rmdir "$lockfile"
        echo "Cannot create temporary payload for $filepath."
        return 1
    }

    # Result files are normally UTF-16LE. Conversion happens on disk, not in a shell variable.
    if ! iconv -f UTF-16LE -t UTF-8 "$filepath" >"$payload" 2>/dev/null; then
        cp -- "$filepath" "$payload" || {
            rm -f "$payload"
            rmdir "$lockfile"
            echo "Cannot prepare payload for $filepath."
            return 1
        }
    fi

    exec {lock_fd}>"$UPLOAD_LOCK_FILE" || {
        rm -f "$payload"
        rmdir "$lockfile"
        echo "Cannot create upload lock for $filepath."
        return 1
    }
    flock -x "$lock_fd" || {
        exec {lock_fd}>&-
        rm -f "$payload"
        rmdir "$lockfile"
        echo "Cannot acquire upload lock for $filepath."
        return 1
    }

    sleep "$UPLOAD_INTERVAL"
    echo "Uploading $filepath (curl retries: $UPLOAD_RETRIES)..."
    http_code="000"
    curl_exit=0
    http_code=$(curl --silent --show-error --fail --output /dev/null --write-out "%{http_code}" \
        --request POST "$API_URL" \
        --header "Content-Type: application/json" \
        --header "x-sumracing-api-key: $API_KEY" \
        --data-binary "@$payload" \
        --connect-timeout "${UPLOAD_CONNECT_TIMEOUT:-30}" \
        --retry "$UPLOAD_RETRIES" \
        --retry-delay "$RETRY_DELAY" \
        --retry-max-time 0) || curl_exit=$?

    flock -u "$lock_fd"
    exec {lock_fd}>&-

    if [ "$curl_exit" -eq 0 ] && [[ "$http_code" == 2?? ]]; then
        if mv -- "$filepath" "$BACKUP_DIR"; then
            echo "Uploaded $filepath and moved it to $BACKUP_DIR."
        else
            echo "Upload succeeded but could not move $filepath to $BACKUP_DIR."
        fi
    else
        echo "Upload failed for $filepath (curl_exit=$curl_exit, http_code=$http_code). File kept for retry."
    fi

    rm -f "$payload"
    rmdir "$lockfile" 2>/dev/null || true
}

queue_existing_files() {
    local filepath
    while IFS= read -r -d '' filepath; do
        upload_file "$filepath"
    done < <(find "$WATCH_DIR" -maxdepth 1 -type f -name '*.json' -print0)
}

echo "AUTO_SEND_RESULT is enabled. Watching directory: $WATCH_DIR"
# Keep startup uploads ordered without blocking the game server from starting.
queue_existing_files &

inotifywait -m -e close_write -e moved_to --format "%f" "$WATCH_DIR" |
while IFS= read -r filename; do
    [[ "$filename" == .* || "${filename##*.}" != "json" ]] && continue
    upload_file "$WATCH_DIR/$filename" &
done
