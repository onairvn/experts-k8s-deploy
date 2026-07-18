#!/bin/bash

# Usage: ./edit.sh <yaml-file> <container-name> <new-tag>

FILE=$1
CONTAINER_NAME=$2
NEW_TAG=$3

if [ -z "$FILE" ] || [ -z "$CONTAINER_NAME" ] || [ -z "$NEW_TAG" ]; then
  echo "Usage: $0 <yaml-file> <container-name> <new-tag>"
  exit 1
fi

# Try containers array pattern first (name: xxx → update next tag:)
if grep -q "name:.*${CONTAINER_NAME}" "$FILE" 2>/dev/null; then
  awk -v cname="$CONTAINER_NAME" -v ntag="$NEW_TAG" '
    $0 ~ "name:[ ]*"cname"$" {in_container=1}
    in_container && $0 ~ "tag:" {
      sub(/tag:.*/, "tag: "ntag)
      in_container=0
    }
    {print}
  ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
else
  # Container name not matched. Guard against the multi-container blanket-replace bug:
  # if the file has more than one `tag:` line, a blanket sed would bump EVERY container
  # (e.g. cos-be build wrongly bumping be-el/admin/student → ImagePullBackOff). Fail loud.
  tag_count=$(grep -cE '^[[:space:]]*tag:' "$FILE")
  if [ "$tag_count" -gt 1 ]; then
    echo "ERROR: container '${CONTAINER_NAME}' not found in multi-tag file '${FILE}' (${tag_count} tag: lines)." >&2
    echo "Refusing blanket tag replace. Align the lemon app name with the values container 'name:'." >&2
    exit 1
  fi
  # Genuinely flat single-tag file: update image.tag directly.
  sed -i "s|tag:.*|tag: \"${NEW_TAG}\"|" "$FILE"
fi
