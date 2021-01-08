#!/bin/bash

# Example command: b2_download.sh > file

# App Key ID here
ID=""
# App Key
KEY=""
# Name of file to download
FILE=""
# Name of bucket containing file (App Key must have access to this)
BUCKET=""

# Get auth token
RESP=$(curl "https://api.backblaze.com/b2api/v2/b2_authorize_account" -u "$ID:$KEY" -s )

# Extract important parts
AUTH_TOKEN=$( echo "$RESP" | jq -r '.authorizationToken' )
DOWNLOAD_URL=$( echo "$RESP" | jq -r '.downloadUrl' )
URL="$DOWNLOAD_URL/file/$BUCKET/$FILE"

# Fetch the file
curl -s -H "Authorization: $AUTH_TOKEN" "$URL"
