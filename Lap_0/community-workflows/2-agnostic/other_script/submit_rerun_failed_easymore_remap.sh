#!/bin/bash
#SBATCH --job-name=easymore_rerun
#SBATCH --array=0-99  # Adjust based on number of unique failed files
#SBATCH --output=logs_rerun/output_%A_%a.out
#SBATCH --error=logs_rerun/error_%A_%a.err
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --account=rrg-alpie

module restore scimods
source ~/virtual-envs/scienv/bin/activate

INPUT_DIR=/scratch/zelalem/cantrans-models/casr-datatool-outputs
OUTPUT_DIR=/scratch/zelalem/cantrans-models/casr-easymore-outputs/
TEMP_DIR=$OUTPUT_DIR/cache/
SHAPEFILE=/home/zelalem/github-repos/community-workflows/1-geofabric/CanTrans-merit-geofabric/sorted_agg_MERIT_CanTrans_subbasins.shp
REMAPPING_NC=$TEMP_DIR/remapped_remapping.nc
FAILED_LIST=$OUTPUT_DIR/unique_failed.txt

# ?? Collect and deduplicate all failed file logs
if [ "$SLURM_ARRAY_TASK_ID" -eq 0 ]; then
    echo "?? Aggregating failed files into $FAILED_LIST"
    cat $OUTPUT_DIR/failed_*.txt | sort -u > "$FAILED_LIST"
fi

# Wait for task 0 to finish collecting
sleep 10

# ?? Get file corresponding to array task ID
INPUT_FILE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$FAILED_LIST")

if [ -z "$INPUT_FILE" ]; then
    echo "No input file for task ID $SLURM_ARRAY_TASK_ID"
    exit 0
fi

echo "?? Rerunning failed file: $INPUT_FILE"

# ?? Run the same script used in the main job
./run_easymore_remap.py "$INPUT_FILE" \
    --output-dir "$OUTPUT_DIR" \
    --temp-dir "$TEMP_DIR" \
    --shapefile "$SHAPEFILE" \
    --remapping-nc "$REMAPPING_NC"
