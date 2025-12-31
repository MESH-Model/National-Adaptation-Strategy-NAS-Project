#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=nco_subset
#SBATCH --output=logs/nco_subset_%A_%a.out
#SBATCH --error=logs/nco_subset_%A_%a.err
#SBATCH --array=0-687 #148   # 149 array jobs
#SBATCH --cpus-per-task=1
#SBATCH --time=00:58:00
#SBATCH --mem=8G

# find /scratch/zelalem/cciw1/historical/r1i1p2f1/CRCM5/v1-r1/1hr/ -type f -path '*/v20231221/*.nc' | sort > nc_files.txt
# find /project/6102189/data/meteorological-data/ouranos-mrcc5-cmip6/CanESM5/ssp126/r1i1p2f1/CRCM5/v1-r1/1hr/ -type f -path '*/v20231214/*.nc' | sort > nc_ssp585_files.txt

### --- Load environment --- ###
module load nco  # Or use: conda activate your_env

### --- Directories --- ###
OUT_DIR="/scratch/sujata1/cciw1/subset_ssp126"
mkdir -p "$OUT_DIR"

### --- Config --- ###
FILES_PER_TASK=1  # 3000 files / 149 jobs ˜ 20.13 ? round up to 21
START_LINE=$(( SLURM_ARRAY_TASK_ID * FILES_PER_TASK + 1 ))
END_LINE=$(( START_LINE + FILES_PER_TASK - 1 ))

echo "Task ID: $SLURM_ARRAY_TASK_ID processing lines $START_LINE to $END_LINE"

### --- Process each file in this task's slice --- ###
LINE_NUM=$START_LINE
while [ "$LINE_NUM" -le "$END_LINE" ]; do
#  FILE=$(sed -n "${LINE_NUM}p" nc_files.txt)
  FILE=$(sed -n "${LINE_NUM}p" nc_ssp126_files.txt)

  # Stop if we go beyond file count
  if [ -z "$FILE" ]; then
    break
  fi

  if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    ((LINE_NUM++))
    continue
  fi

  BASENAME=$(basename "$FILE")
  OUTPUT_FILE="$OUT_DIR/$BASENAME"

  echo "Processing $FILE -> $OUTPUT_FILE"

  ncks -O -4 -L 1 \
    -d rlat,-7.225,35.345 \
    -d rlon,-29.975,29.315 \
    "$FILE" "$OUTPUT_FILE"

  ((LINE_NUM++))
done