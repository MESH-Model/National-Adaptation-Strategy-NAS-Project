#!/bin/bash
#SBATCH --job-name=casr_subset
#SBATCH --account=rrg-alpie
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/casr_%A_%a.out
#SBATCH --error=logs/casr_%A_%a.err
#SBATCH --array=1-19   # 20 tasks

set -euo pipefail

# ==================================================
# USER INPUT
# ==================================================
LIST=missing_files.txt          # contains *.nc

# ==================================================
# MODULES
# ==================================================
module load cdo
module load nco

# ==================================================
# PATHS
# ==================================================
INROOT=/project/6102189/NAS/casr3p2
OUTROOT=/home/zelalem/scratch/cantrans-models/casr3p2-datatool-outputs1991
mkdir -p logs "${OUTROOT}"

# ==================================================
# TOTAL FILES
# ==================================================
TOTAL=$(wc -l < "${LIST}")
NUM_TASKS=20  # must match #SBATCH --array range
TASK_ID=${SLURM_ARRAY_TASK_ID}  # 0-based

# ==================================================
# CALCULATE FILE RANGE FOR THIS TASK
# ==================================================
FILES_PER_TASK=$(( (TOTAL + NUM_TASKS - 1) / NUM_TASKS ))  # ceiling division
START=$(( TASK_ID * FILES_PER_TASK + 1 ))
END=$(( START + FILES_PER_TASK - 1 ))
(( END > TOTAL )) && END=${TOTAL}

# Task-specific work directory
WORKROOT=/tmp/${USER}/casr_${SLURM_JOB_ID}_${TASK_ID}
mkdir -p "${WORKROOT}"

echo "Task ${TASK_ID}: processing files ${START} to ${END} of ${TOTAL}"

# ==================================================
# PROCESS FILES
# ==================================================
for IDX in $(seq "${START}" "${END}"); do
    RAW=$(sed -n "${IDX}p" "${LIST}")
    TS=$(basename "${RAW}" .nc)

    INFILE="${INROOT}/${TS}.nc"
    OUTFILE="${OUTROOT}/casr_${TS}.nc"

    [[ -f "${OUTFILE}" ]] && continue

    TMP1="${WORKROOT}/subset_${TS}.nc"
    TMP2="${WORKROOT}/lonfix_${TS}.nc"

    echo "Processing ${TS}"

    # 1. Subset FIRST (datatool behavior)
    cdo -s -L -f nc4 -z zip \
        -sellonlatbox,-131.50,-57.50,40.15,82.50 \
        -selvar,\
CaSR_v3.2_A_PR0_SFC,\
CaSR_v3.2_P_FB_SFC,\
CaSR_v3.2_P_FI_SFC,\
CaSR_v3.2_P_P0_SFC,\
CaSR_v3.2_P_HU_09975,\
CaSR_v3.2_P_TT_09975,\
CaSR_v3.2_P_UVC_09975,\
CaSR_v3.2_P_PR0_SFC,\
CaSR_v3.2_P_VVC_09975,\
CaSR_v3.2_P_UUC_09975 \
        "${INFILE}" \
        "${TMP1}"

    # 2. Longitude fix AFTER subsetting
    ncap2 -O -s 'where(lon>180) lon=lon-360' \
        "${TMP1}" \
        "${OUTFILE}"

    rm -f "${TMP1}"
done

# Clean task-specific work directory
rm -rf "${WORKROOT}"
echo "Task ${TASK_ID} finished"