#!/bin/bash
#SBATCH --job-name=cdo_chunked
#SBATCH --output=logs/output_%A_%a.out
#SBATCH --error=logs/error_%A_%a.err
#SBATCH --account=rpp-kshook
#SBATCH --array=0-149
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=16000M
#SBATCH --time=00:40:00

# Load CDO module
module load cdo
module load nco

# Directory containing input files
INPUT_DIR="/scratch/zelalem/CanTrans-models/easymore-outputs/batches_CaSRv3p1"

# Get sorted list of .nc files in the directory
FILES=($(ls "$INPUT_DIR"/*.nc | sort))

# Total number of files
NUM_FILES=${#FILES[@]}

# Check if array index is within range
if [ "$SLURM_ARRAY_TASK_ID" -ge "$NUM_FILES" ]; then
  echo "Index $SLURM_ARRAY_TASK_ID is out of range (only $NUM_FILES files). Exiting."
  exit 1
fi

# File to process
INPUT_FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

# Rename dimension in-place
echo "Processing $INPUT_FILE"
ncrename -d ID,subbasin "$INPUT_FILE"