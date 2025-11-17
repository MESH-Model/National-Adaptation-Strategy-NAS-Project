#!/bin/bash
#SBATCH --job-name=mesh_run
#SBATCH --account=def-kshook
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --time=23:58:00
#SBATCH --mem=128G
#SBATCH --array=0 #-1

set -euo pipefail

# === Configuration =====
GRUs=("Average_GRU_Params")                        # List of GRU parameterization
#GRUs=("Average_GRU_Params" "Distributed_GRU_Params")  # List of GRU parameterization
GRU="${GRUs[$SLURM_ARRAY_TASK_ID]}"
FORCING="CaSRv3p1"
JOB_DIR="mesh_rte_pre_forcast"
BASE_DIR="/scratch/zelalem/CanTrans-models/subbasin_MESH_run"
DDB_DIR="${BASE_DIR}/subbasin_ddb"
MASTER_DIR="${BASE_DIR}/subbasin_master"
CLIMATE_DIR="${BASE_DIR}/MESH_${FORCING}/${GRU}"
TARGET_DIR="${BASE_DIR}/MESH_${FORCING}/${GRU}/${JOB_DIR}"
PARAMS_DIR="${BASE_DIR}/subbasin_params"

# ===== Start the Routing ======
echo "🚀 Starting mesh_rte run for GRU=${GRU} at $(date)"
mkdir -p "${TARGET_DIR}" && cd "${TARGET_DIR}"
mkdir -p "OBASINAVG"

# === Link or copy input files ======
ln -sf "${CLIMATE_DIR}/mesh_lss_pre_forcast/merged_RFF_H_GRD.nc" RFF_H_GRD.nc
ln -sf "${DDB_DIR}/MESH_drainage_database_Polish_0p05_0p02_0p01.nc" MESH_drainage_database.nc
ln -sf "${MASTER_DIR}/MESH_input_run_options_RTE.ini" MESH_input_run_options.ini
ln -sf "${MASTER_DIR}/MESH_parameters_hydrology.ini" MESH_parameters_hydrology.ini
ln -sf "${MASTER_DIR}/MESH_parameters_CLASS_${FORCING}.ini" MESH_parameters_CLASS.ini
#ln -sf "${MASTER_DIR}/MESH_parameters_CLASS_RTE.ini" MESH_parameters_CLASS.ini
ln -sf "${MASTER_DIR}/MESH_input_streamflow.tb0" MESH_input_streamflow.tb0
ln -sf "${MASTER_DIR}/MESH_input_soil_levels.txt" MESH_input_soil_levels.txt
ln -sf "${MASTER_DIR}/MESH_input_reservoir.txt" MESH_input_reservoir.txt
ln -sf "${MASTER_DIR}/minmax_parameters.txt" minmax_parameters.txt
ln -sf "${MASTER_DIR}/outputs_balance_rte.txt" outputs_balance.txt
ln -sf "${MASTER_DIR}/Metrics_BAD.txt" Metrics_BAD.txt
ln -sf "${PARAMS_DIR}/${GRU}/CanTransModel_MESH_parameters_noIWF.nc" MESH_parameters.nc
# ln -sf "${MASTER_DIR}/${GRU}/MESH_parameters.txt" MESH_parameters.txt
ln -sf "${MASTER_DIR}/run_mesh_rte.sh" run_mesh_rte.sh


# === Run the model ======
echo "🚧 Running model for GRU=${GRU}..."
chmod +x ./run_mesh_rte.sh
./run_mesh_rte.sh > mesh_rte.log 2>&1

echo "✅ mesh_rte run completed for GRU=${GRU} at $(date)"
