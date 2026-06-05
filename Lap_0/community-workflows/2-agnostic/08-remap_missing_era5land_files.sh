#!/bin/bash

OUTPUT="missing_era5l_files.txt"
DATA_DIR="/project/6102189/zelalem/era5land-datatool-outputs_withunit"
MISSING_DIR="$DATA_DIR/missing_files"

# Prepare output file
> "$OUTPUT"

# Create missing_files directory
mkdir -p "$MISSING_DIR"

echo "Scanning logs for completed files..."

# Extract all era5l YYYY MM entries from logs
grep -hRo "era5l\.[0-9]\{4\}\.[0-9]\{2\}\.subset\.nc" \
    /home/zelalem/scratch/cantrans-models/era5land-easymore-outputs/cache{1950..2024}/easymore.log \
    | awk -F. '{print $2,$3}' \
    | sort -k1,1 -k2,2n \
    | while read YEAR MONTH; do
        
        # Convert month safely (avoid octal issues)
        MONTH_DEC=$((10#$MONTH))

        # When switching to a new year
        if [[ "$YEAR" != "$CURRENT_YEAR" ]]; then
            
            # Fill in missing months for previous year
            if [[ -n "$CURRENT_YEAR" ]]; then
                for M_DEC in $(seq $((LAST_MONTH_DEC+1)) 12); do
                    
                    M=$(printf "%02d" $M_DEC)
                    FILE="era5l.${CURRENT_YEAR}.${M}.subset.nc"
                    REALFILE="${DATA_DIR}/${FILE}"
                    LINKFILE="${MISSING_DIR}/${FILE}"

                    echo "$FILE" >> "$OUTPUT"

                    if [[ -f "$REALFILE" ]]; then
                        ln -sf "$REALFILE" "$LINKFILE"
                    else
                        echo "WARNING: Missing target file: $REALFILE" >&2
                    fi
                done
            fi

            CURRENT_YEAR=$YEAR
            LAST_MONTH_DEC=$MONTH_DEC
        
        else
            LAST_MONTH_DEC=$MONTH_DEC
        fi
    done


# Process the last year outside the loop
if [[ -n "$CURRENT_YEAR" ]]; then
    for M_DEC in $(seq $((LAST_MONTH_DEC+1)) 12); do
        
        M=$(printf "%02d" $M_DEC)
        FILE="era5l.${CURRENT_YEAR}.${M}.subset.nc"
        REALFILE="${DATA_DIR}/${FILE}"
        LINKFILE="${MISSING_DIR}/${FILE}"

        echo "$FILE" >> "$OUTPUT"

        if [[ -f "$REALFILE" ]]; then
            ln -sf "$REALFILE" "$LINKFILE"
        else
            echo "WARNING: Missing target file: $REALFILE" >&2
        fi
    done
fi

echo "Missing files listed in: $OUTPUT"
echo "Symbolic links created (if target exists) in: $MISSING_DIR"