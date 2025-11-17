#!/bin/bash
#SBATCH --job-name=mesh_run
#SBATCH --account=rpp-kshook
#SBATCH --array=47,135 #0-141
#SBATCH --cpus-per-task=8
#SBATCH --time=04:58:00
#SBATCH --mem=8G

# === Configuration ===
CHUNK_SIZE=512
FINAL_END=72507  # Last index for the final chunk
FORCING="CaSRv3p1"
BASE_DIR="/scratch/zelalem/CanTrans-models/subbasin_MESH_run"
CLIMATE_DIR="${BASE_DIR}/subbasin_${FORCING}_forcing"
DDB_DIR="${BASE_DIR}/subbasin_ddb"
MASTER_DIR="${BASE_DIR}/subbasin_master"
#PARAMS_DIR="${BASE_DIR}/subbasin_params"

# === Create logs directory (if it doesn't exist) ===
LOGDIR="mesh_distparams_${FORCING}/logs"
mkdir -p "$LOGDIR"
# Redirect logs manually
exec > "${LOGDIR}/output_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.log" 2> "${LOGDIR}/error_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.log"
echo "🚀 Starting task ${SLURM_ARRAY_TASK_ID} in mesh_${FORCING}/logs at $(date)"

# === Dynamically rename job (only affects logging and status info, not Slurm tracking)
JOB_NAME="mesh_${FORCING}_run"
scontrol update JobName=${JOB_NAME} JobId=${SLURM_JOB_ID}

# === Compute chunk indices ===
i=${SLURM_ARRAY_TASK_ID}
START=$((i * CHUNK_SIZE))
if [ "$i" -eq 141 ]; then
    END=$FINAL_END
else
    END=$((START + CHUNK_SIZE - 1))
fi
JOB_DIR="Run_${START}_to_${END}"
TARGET_DIR="${BASE_DIR}/mesh_distparams_${FORCING}/${JOB_DIR}"
echo "🚀 Starting chunk ${i}: ${START}-${END} at $(date)"
mkdir -p "${TARGET_DIR}/OBASINAVG"
cd "${TARGET_DIR}"

# === Link or copy input files ===
ln -sf "${CLIMATE_DIR}/MESH_forcing_subbasin_${START}_to_${END}.nc" MESH_forcing_subbasin.nc
ln -sf "${DDB_DIR}/MESH_drainage_database_${START}_to_${END}.nc" MESH_drainage_database.nc
#ln -sf "${PARAMS_DIR}/MESH_parameters_${START}_to_${END}.nc" MESH_parameters.nc
ln -sf "${MASTER_DIR}/MESH_input_run_options_${FORCING}.ini" MESH_input_run_options.ini
ln -sf "${MASTER_DIR}/MESH_parameters_hydrology.ini" MESH_parameters_hydrology.ini
ln -sf "${MASTER_DIR}/Metrics_BAD.txt" Metrics_BAD.txt
ln -sf "${MASTER_DIR}/minmax_parameters.txt" minmax_parameters.txt
ln -sf "${MASTER_DIR}/outputs_balance.txt" outputs_balance.txt
ln -sf "${MASTER_DIR}/MESH_parameters.txt" MESH_parameters.txt
ln -sf "${MASTER_DIR}/MESH_input_soil_levels.txt" MESH_input_soil_levels.txt
ln -sf "${MASTER_DIR}/MESH_input_reservoir.txt" MESH_input_reservoir.txt
ln -sf "${MASTER_DIR}/mesh_run.sh" mesh_run.sh

# === Handle MESH_parameters_CLASS.ini file ===
if [ "$i" -eq 141 ]; then
    cp "${MASTER_DIR}/MESH_parameters_CLASS_${FORCING}.ini" MESH_parameters_CLASS.ini
    sed -i '4s/512/316/' MESH_parameters_CLASS.ini
else
    ln -sf "${MASTER_DIR}/MESH_parameters_CLASS_${FORCING}.ini" MESH_parameters_CLASS.ini
fi

# === Run the model ===
./mesh_run.sh > model_output.log 2>&1
EXIT_CODE=$?

# === Evaluate success/failure ===
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Chunk ${i} (${START}-${END}) completed successfully at $(date)"
else
    echo "❌ Chunk ${i} (${START}-${END}) failed at $(date)"
    echo "🔍 Check model_output.log for details"
    exit $EXIT_CODE
fi