#!/bin/bash

BASE_URL="https://hpfx.collab.science.gc.ca/~scar700/rcas-casr/data/CaSRv3.2/netcdf"
LIST="missing_files.txt"
TARGET_DIR="/project/6102189/NAS/casr3p2"

mkdir -p "$TARGET_DIR"

while IFS= read -r FILE; do
    [[ -z "$FILE" ]] && continue
    URL="$BASE_URL/$FILE"
    DEST="$TARGET_DIR/$FILE"
    mkdir -p "$(dirname "$DEST")"
    echo "Downloading $URL ? $DEST"
    wget -c "$URL" -O "$DEST"
done < "$LIST"
