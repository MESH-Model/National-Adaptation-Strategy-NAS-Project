#!/bin/bash
#SBATCH --job-name=easymore_array
#SBATCH --array=0-149
#SBATCH --output=logs_CaSRv3p1/output_%A_%a.out
#SBATCH --error=logs_CaSRv3p1/error_%A_%a.err
#SBATCH --time=02:58:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --account=rrg-alpie

module restore scimods
source ~/virtual-envs/scienv/bin/activate

FILES_PER_TASK=108
INPUT_DIR=/scratch/zelalem/cantrans-models/casr-datatool-outputs
OUTPUT_DIR=/scratch/zelalem/cantrans-models/casr-easymore-outputs/
TEMP_DIR=$OUTPUT_DIR/cache/
SHAPEFILE=/home/zelalem/github-repos/community-workflows/1-geofabric/CanTrans-merit-geofabric/sorted_agg_MERIT_CanTrans_subbasins.shp
REMAPPING_NC=$TEMP_DIR/remapped_remapping.nc
FAILED_LOG=$OUTPUT_DIR/failed_$SLURM_ARRAY_TASK_ID.txt

mkdir -p "$TEMP_DIR"

# Get file list
mapfile -t FILES < <(find "$INPUT_DIR" -type f -name "*.nc" | sort)
START=$((SLURM_ARRAY_TASK_ID * FILES_PER_TASK))
END=$((START + FILES_PER_TASK))

for ((i=START; i<END && i<${#FILES[@]}; i++)); do
    INPUT_FILE="${FILES[$i]}"
    echo "?? Processing: $INPUT_FILE"
    ./run_easymore_remap.py "$INPUT_FILE" \
        --output-dir "$OUTPUT_DIR" \
        --temp-dir "$TEMP_DIR" \
        --shapefile "$SHAPEFILE" \
        --remapping-nc "$REMAPPING_NC" \
        --failed-log "$FAILED_LOG"
done
