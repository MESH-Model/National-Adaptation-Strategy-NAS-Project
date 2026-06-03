#!/bin/bash
#SBATCH --job-name=CanESM5_easymore
#SBATCH --output=logs_CanESM5/output_%A_%a.out
#SBATCH --error=logs_CanESM5/error_%A_%a.err
#SBATCH --account=rrg-alpie
#SBATCH --array=0-687
#SBATCH --cpus-per-task=1
#SBATCH --mem=64000M
#SBATCH --time=04:00:00

### Load modules and environment
module restore scimods
source ~/virtual-envs/scienv/bin/activate

set -euo pipefail
mkdir -p logs_CanESM5

INPUT_DIR="/scratch/sujata1/cciw1/subset_ssp126"
OUTPUT_DIR="/project/6102189/sujata1/easymore_outputs/ssp126/"
CACHE_DIR_BASE="/scratch/sujata1/cciw1/easymore-outputs/CMIP6/cache/"
CACHE_DIR="${CACHE_DIR_BASE}/cache_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}/"
REMAP_FILE="/scratch/sujata1/cciw1/easymore-outputs/CMIP6/remapped_remap_remapping.nc"
SHAPEFILE="/scratch/sujata1/cciw1/new_agg_basin/sorted_agg_MERIT_CanTrans_subbasins.shp"
SHAPEFILE_ID="Rank"
DIMENSION_ID="subbasin"
EXPECTED_SUBBASINS=77017
LOGFILE="${OUTPUT_DIR}/subbasin_check_log.txt"

mkdir -p "$OUTPUT_DIR" "$CACHE_DIR"

# === detect NetCDF input files ===
INPUT_FILES=($(find "$INPUT_DIR" -maxdepth 1 -type f -name "*.nc" | sort))
TOTAL_FILES=${#INPUT_FILES[@]}
if [ "$TOTAL_FILES" -eq 0 ]; then
  echo "❌ No NetCDF files found in $INPUT_DIR"
  exit 1
fi

if [ "$SLURM_ARRAY_TASK_ID" -ge "$TOTAL_FILES" ]; then
  echo "No file for SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID (Total: $TOTAL_FILES)"
  exit 0
fi

# === get current file ===
INPUT_FILE="${INPUT_FILES[$SLURM_ARRAY_TASK_ID]}"
BASENAME=$(basename "$INPUT_FILE")
VAR=$(echo "$BASENAME" | cut -d'_' -f1)
OUTFILE="${OUTPUT_DIR}/remapped_remap_remapped_${BASENAME}"

echo "[$(date)] Processing file #$SLURM_ARRAY_TASK_ID: $BASENAME (var=$VAR)"

# === Function to extract subbasin count ===
check_subbasin_count () {
    ncdump -h "$1" 2>/dev/null | grep -Eo "subbasin = [0-9]+" | awk '{print $3}'
}

# === Easymore wrapper ===
run_easymore () {
    easymore cli \
      --case-name "remapped_remap" \
      --source-nc "$INPUT_FILE" \
      --shapefile "$SHAPEFILE" \
      --shapefile-id "$SHAPEFILE_ID" \
      --variable "$VAR" \
      --variable-lon lon \
      --variable-lat lat \
      --remapped-var-id "$DIMENSION_ID" \
      --remapped-dim-id "$DIMENSION_ID" \
      --output-dir "$OUTPUT_DIR" \
      --remap-file "$REMAP_FILE" \
      --cache "$CACHE_DIR" \
      --skip-checks
}

# === Step 1: Skip if valid file already exists ===
if [ -f "$OUTFILE" ]; then
    count=$(check_subbasin_count "$OUTFILE" || echo 0)
    if [[ "$count" -eq "$EXPECTED_SUBBASINS" ]]; then
        echo "✅ Valid file exists (subbasin=$count): $OUTFILE"
        exit 0
    else
        echo "⚠️ Invalid file found (subbasin=$count, expected=$EXPECTED_SUBBASINS). Re-running remapping..."
        rm -f "$OUTFILE"
    fi
fi

# === Step 2: First run ===
run_easymore

# === Step 3: Validate output ===
count=$(check_subbasin_count "$OUTFILE" || echo 0)
if [[ "$count" -ne "$EXPECTED_SUBBASINS" ]]; then
    echo "⚠️ Subbasin count mismatch ($count != $EXPECTED_SUBBASINS). Retrying remapping once more..."
    rm -f "$OUTFILE"
    run_easymore
    count=$(check_subbasin_count "$OUTFILE" || echo 0)
fi

# === Step 4: Final validation ===
if [[ "$count" -eq "$EXPECTED_SUBBASINS" ]]; then
    echo "✅ Finished and validated: $OUTFILE (subbasin=$count)"
    echo "$(date) ✅ OK: $BASENAME subbasin=$count" >> "$LOGFILE"
else
    echo "❌ Still invalid after retry (subbasin=$count). Please inspect: $OUTFILE"
    echo "$(date) ❌ FAIL: $BASENAME subbasin=$count" >> "$LOGFILE"
fi
