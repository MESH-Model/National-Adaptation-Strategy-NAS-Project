#!/bin/bash
#SBATCH --job-name=mesh_run
#SBATCH --account=def-kshook
#SBATCH --array=0-148 #40,42,46,47,134,135   #30,31,37,38,39,41,43,132,141,148 #0-148
#SBATCH --cpus-per-task=8
#SBATCH --time=08:58:00
#SBATCH --mem=8G

# === Configuration ===
CHUNK_SIZE=520
FINAL_END=77016                       # Last index for the final chunk
FORCING="CaSRv3p1"                    # "CaSRv3p1" #CaSRv1p1
GRU="Distributed_GRU_Params"          # "Average_GRU_Params" #"Distributed_GRU_Params"
MODELRUN="mesh_lss"
BASE_DIR="/scratch/zelalem/CanTrans-models/subbasin_MESH_run"
CLIMATE_DIR="${BASE_DIR}/subbasin_forcing_${FORCING}"
DDB_DIR="${BASE_DIR}/subbasin_ddb"
MASTER_DIR="${BASE_DIR}/subbasin_master"
PARAMS_DIR="${BASE_DIR}/subbasin_params"

# === Create logs directory (if it doesn't exist) ===
LOGDIR="MESH_${FORCING}/${GRU}/${MODELRUN}/logs"
mkdir -p "$LOGDIR"

FORCINGDIR="MESH_${FORCING}"
mkdir -p "$FORCINGDIR"

GRUDIR="MESH_${FORCING}/${GRU}"
mkdir -p "$GRUDIR"

# === Redirect logs manually
exec > "${LOGDIR}/output_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.log" 2> "${LOGDIR}/error_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.log"
echo "🚀 Starting task ${SLURM_ARRAY_TASK_ID} in mesh_${FORCING}/logs at $(date)"

# === Dynamically rename job (only affects logging and status info, not Slurm tracking)
JOB_NAME="mesh_${FORCING}_run"
scontrol update JobName=${JOB_NAME} JobId=${SLURM_JOB_ID}

# === Compute chunk indices ===
i=${SLURM_ARRAY_TASK_ID}
START=$((i * CHUNK_SIZE))
if [ "$i" -eq 148 ]; then
    END=$FINAL_END
else
    END=$((START + CHUNK_SIZE - 1))
fi
JOB_DIR="Run_${START}_to_${END}"
TARGET_DIR="${BASE_DIR}/MESH_${FORCING}/${GRU}/${MODELRUN}/${JOB_DIR}"
echo "🚀 Starting chunk ${i}: ${START}-${END} at $(date)"
mkdir -p "${TARGET_DIR}/OBASINAVG"
cd "${TARGET_DIR}"

# === Link or copy input files ===
ln -sf "${CLIMATE_DIR}/MESH_forcing_subbasin_${START}_to_${END}.nc" MESH_forcing_subbasin.nc
ln -sf "${DDB_DIR}/MESH_drainage_database_${START}_to_${END}.nc" MESH_drainage_database.nc
ln -sf "${MASTER_DIR}/MESH_input_run_options_${FORCING}.ini" MESH_input_run_options.ini
ln -sf "${MASTER_DIR}/MESH_parameters_hydrology.ini" MESH_parameters_hydrology.ini
ln -sf "${MASTER_DIR}/MESH_input_soil_levels.txt" MESH_input_soil_levels.txt
ln -sf "${MASTER_DIR}/MESH_input_reservoir.txt" MESH_input_reservoir.txt
ln -sf "${MASTER_DIR}/minmax_parameters.txt" minmax_parameters.txt
ln -sf "${MASTER_DIR}/outputs_balance_lss.txt" outputs_balance.txt
ln -sf "${MASTER_DIR}/Metrics_BAD.txt" Metrics_BAD.txt
ln -sf "${PARAMS_DIR}/${GRU}/MESH_parameters_${START}_to_${END}.nc" MESH_parameters.nc
#ln -sf "${MASTER_DIR}/MESH_parameters.txt" MESH_parameters.txt

ln -sf "${MASTER_DIR}/run_mesh_lss.sh" run_mesh_lss.sh

# === Handle MESH_parameters_CLASS.ini file ===
if [ "$i" -eq 148 ]; then
    cp "${MASTER_DIR}/MESH_parameters_CLASS_${FORCING}.ini" MESH_parameters_CLASS.ini
    sed -i '4s/520/57/' MESH_parameters_CLASS.ini
else
    ln -sf "${MASTER_DIR}/MESH_parameters_CLASS_${FORCING}.ini" MESH_parameters_CLASS.ini
fi

# === Run the model ===
chmod +x ./run_mesh_lss.sh
./run_mesh_lss.sh > model_lss.log 2>&1
EXIT_CODE=$?

# === Evaluate success/failure ===
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Chunk ${i} (${START}-${END}) completed successfully at $(date)"
else
    echo "❌ Chunk ${i} (${START}-${END}) failed at $(date)"
    echo "🔍 Check model_output.log for details"
    exit $EXIT_CODE
fi