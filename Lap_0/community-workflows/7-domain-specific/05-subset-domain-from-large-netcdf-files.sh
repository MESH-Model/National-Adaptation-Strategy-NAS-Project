#!/bin/bash
#SBATCH --job-name=subset
#SBATCH --output=logs/subset%A_%a.out
#SBATCH --error=logs/subset%A_%a.err
#SBATCH --account=rrg-alpie
#SBATCH --array=0-45
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=02:50:00

### Load required modules and virtual environment
module restore scimods
source ~/virtual-envs/scienv/bin/activate

## Make a directory
mkdir -p logs

## Set pipefail
set -euo pipefail

## Add the python block
python <<'EOF'
import xarray as xr
import numpy as np
import os
import glob
import tempfile

# =========================
# SETTINGS
# =========================
INPUT_DIR  = "/scratch/zelalem/cantrans-models/camels-casr3p2-easymore-outputs/easymore-outputs-yearly/"
OUTPUT_DIR = "/scratch/zelalem/cantrans-models/Calibration/GroupCalibration02/easymore-outputs-yearly/"
MASK_FILE  = "/scratch/zelalem/cantrans-models/Calibration/GroupCalibration02/MESH_drainage_database_regrouped_Polish.nc"

dim_data = "subbasin"
dim_key = "Rank_old"
time_chunksize = 5000

os.makedirs(OUTPUT_DIR, exist_ok=True)

# =========================
# FIND INPUT FILES
# =========================
input_files = sorted(glob.glob(os.path.join(INPUT_DIR, "*.nc")))
if not input_files:
    raise RuntimeError("No input files found")

jobs = [(f, os.path.join(OUTPUT_DIR, os.path.basename(f))) for f in input_files]

task_id = int(os.environ.get("SLURM_ARRAY_TASK_ID", 0))
if task_id >= len(jobs):
    raise IndexError(f"Task {task_id} out of range ({len(jobs)} jobs)")

input_nc_path, output_nc_path = jobs[task_id]

print("Task:", task_id)
print("INPUT :", input_nc_path)
print("MASK  :", MASK_FILE)
print("OUTPUT:", output_nc_path)

# =========================
# PROCESS FUNCTION
# =========================
def ultra_fast_subset_preserve_order(input_nc_path, mask_path, output_nc_path):
    os.environ.setdefault("HDF5_USE_FILE_LOCKING", "FALSE")

    # Open datasets
    data = xr.open_dataset(
        input_nc_path,
        chunks={"time": time_chunksize},
        lock=False,
        decode_cf=False,
    )

    mask = xr.open_dataset(mask_path)

    # --- VALIDATIONS ---
    if dim_data not in data.dims:
        raise ValueError(f"Dimension '{dim_data}' not found in {input_nc_path}")

    if dim_key not in mask.variables:
        raise ValueError(f"Variable '{dim_key}' not found in mask file")

    # --- BUILD INDEX ---
    idx = mask[dim_key].values

    if idx.size == 0:
        raise ValueError("Mask index is empty")

    idx = idx[idx > 0].astype(np.int64) - 1

    # Remove duplicates, preserve order
    _, first = np.unique(idx, return_index=True)
    idx = idx[np.sort(first)]

    # --- BOUNDS CHECK ---
    max_valid = data.sizes[dim_data]
    idx = idx[idx < max_valid]

    if idx.size == 0:
        raise ValueError("No valid indices after filtering")

    # --- SUBSET ---
    subset = data.isel({dim_data: idx})

    # --- SAFE CHUNKING ---
    if "time" in subset.dims:
        subset = subset.chunk({"time": time_chunksize})

    # --- ENCODING ---
    encoding = {v: {"zlib": False} for v in subset.data_vars}

    # --- ATOMIC WRITE ---
    with tempfile.NamedTemporaryFile(dir=os.path.dirname(output_nc_path), delete=False) as tmp:
        tmp_path = tmp.name

    subset.to_netcdf(tmp_path, encoding=encoding)

    os.replace(tmp_path, output_nc_path)

    print("Done:", output_nc_path)

# =========================
# RUN
# =========================
ultra_fast_subset_preserve_order(
    input_nc_path,
    MASK_FILE,
    output_nc_path,
)
EOF