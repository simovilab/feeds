#!/usr/bin/env bash
# upload.sh — usage: ./upload.sh <agency> <feed-type> <local-file>
# example: ./upload.sh incofer schedule ./build/incofer-feed.zip
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <agency> <feed-type> <local-file>" >&2
  exit 1
fi

AGENCY="$1"
FEED_TYPE="$2"
LOCAL_FILE_PATH="$3"
SERVER="fabarca@simovi.ucr.ac.cr"
REMOTE_BASE="/opt/feeds/gtfs-data"

# Restrict to safe path segments to avoid writing outside REMOTE_BASE.
if [[ ! "$AGENCY" =~ ^[a-zA-Z0-9_-]+$ ]] || [[ ! "$FEED_TYPE" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: agency and feed-type must only contain letters, numbers, - or _" >&2
  exit 1
fi

if [[ ! -f "$LOCAL_FILE_PATH" ]]; then
  echo "Error: local file not found: ${LOCAL_FILE_PATH}" >&2
  exit 1
fi

# Preserve the local file's extension on the remote (feed.zip, feed.pb, etc).
EXTENSION="${LOCAL_FILE_PATH##*.}"
REMOTE_FILENAME="feed.${EXTENSION}"

REMOTE_DIR="${REMOTE_BASE}/${AGENCY}/${FEED_TYPE}"
ssh "$SERVER" "mkdir -p ${REMOTE_DIR}"
rsync -avz --progress --chmod=F644,D755 "$LOCAL_FILE_PATH" "${SERVER}:${REMOTE_DIR}/${REMOTE_FILENAME}"

echo "Uploaded to https://feeds.simovi.org/${AGENCY}/${FEED_TYPE}/${REMOTE_FILENAME}"
