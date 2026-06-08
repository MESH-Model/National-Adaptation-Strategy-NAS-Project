#!/bin/bash
#SBATCH --job-name=easymore_casr3p1
#SBATCH --account=rrg-alpie
#SBATCH --array=0 #-149
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=01:30:00
#SBATCH --output=logs_CaSRv3p1/output_%A_%a.out
#SBATCH --error=logs_CaSRv3p1/error_%A_%a.err

### Load required modules and virtual environment
module restore scimods
source ~/virtual-envs/scienv/bin/activate

set -euo pipefail

mkdir -p logs_CaSRv3p1

# Properly declare and expand input files as array
shopt -s nullglob
INPUT_FILES=(/scratch/zelalem/cantrans-models/casr-datatool-outputs/*.nc*)
shopt -u nullglob

OUTPUT_DIR="/scratch/zelalem/cantrans-models/casr-easymore-outputs/"
CACHE_DIR="/scratch/zelalem/cantrans-models/casr-easymore-outputs/cache/"
REMAP_FILE="/scratch/zelalem/cantrans-models/casr-easymore-outputs/cache/remapped_remapping.nc"
SHAPEFILE="/home/zelalem/github-repos/community-workflows/1-geofabric/CanTrans-merit-geofabric/sorted_agg_MERIT_CanTrans_subbasins.shp"
SHAPEFILE_ID="Rank"
DIMENSION_ID="subbasin"

TOTAL_FILES=${#INPUT_FILES[@]}
NUM_TASKS=150
CHUNK_SIZE=$(( (TOTAL_FILES + NUM_TASKS - 1) / NUM_TASKS ))

# Ensure SLURM_ARRAY_TASK_ID is set
: "${SLURM_ARRAY_TASK_ID:?SLURM_ARRAY_TASK_ID is not set}"

START_INDEX=$(( SLURM_ARRAY_TASK_ID * CHUNK_SIZE ))
END_INDEX=$(( START_INDEX + CHUNK_SIZE - 1 ))
if [ "$END_INDEX" -ge "$TOTAL_FILES" ]; then
    END_INDEX=$(( TOTAL_FILES - 1 ))
fi

echo "SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID processing files $START_INDEX to $END_INDEX"

for (( i=START_INDEX; i<=END_INDEX; i++ )); do
    INPUT_FILE="${INPUT_FILES[$i]}"
    echo "Processing file $((i+1))/${TOTAL_FILES}: $INPUT_FILE"

    easymore cli \
      --case-name "remapped" \
      --source-nc "$INPUT_FILE" \
      --shapefile "$SHAPEFILE" \
      --shapefile-id "$SHAPEFILE_ID" \
      --variable "CaSR_v3.1_A_PR0_SFC" \
      --variable "CaSR_v3.1_P_FB_SFC" \
      --variable "CaSR_v3.1_P_FI_SFC" \
      --variable "CaSR_v3.1_P_P0_SFC" \
      --variable "CaSR_v3.1_P_HU_09975" \
      --variable "CaSR_v3.1_P_TT_09975" \
      --variable "CaSR_v3.1_P_UVC_09975" \
      --variable "CaSR_v3.1_P_PR0_SFC" \
      --variable "CaSR_v3.1_P_VVC_09975" \
      --variable "CaSR_v3.1_P_UUC_09975" \
      --variable-lon lon \
      --variable-lat lat \
      --remapped-var-id "$DIMENSION_ID" \
      --remapped-dim-id "$DIMENSION_ID" \
      --output-dir "$OUTPUT_DIR" \
      --remap-file "$REMAP_FILE" \
      --cache "$CACHE_DIR" \
      --skip-checks
      --complevel 9
done

echo "Task $SLURM_ARRAY_TASK_ID finished processing files $START_INDEX to $END_INDEX."