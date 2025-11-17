#!/bin/bash
#SBATCH --account=def-kshook
#SBATCH --job-name=merge_subbasin_array
#SBATCH --output=logs/%x_%A_%a_%j.out
#SBATCH --error=logs/%x_%A_%a_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=05:59:00

mkdir -p logs

# === select cases =======
GRU="Average_GRU_Params"
#GRU=Distributed_GRU_Params" 
FORCING="CaSRv2p1"
#FORCING="CaSRv3p1"

# === Filename-variable pairs ====== RFF_H_GRD.nc  RFF 
filenames=(ET_D_GRD.nc RFF_D_GRD.nc SNO_D_GRD.nc LQWSSNO_D_GRD.nc ALWSSOL_D_IG1_GRD.nc ALWSSOL_D_IG2_GRD.nc ALWSSOL_D_IG3_GRD.nc ALWSSOL_D_IG4_GRD.nc)
variables=(ET RFF SNO LQWSSNO ALWSSOL ALWSSOL ALWSSOL ALWSSOL)

# === Auto-submit as array job ======
if [ -z "${SLURM_ARRAY_TASK_ID:-}" ]; then
    echo "?? Resubmitting as array job..."
    sbatch --array=0-$((${#filenames[@]} - 1)) "$0"
    exit 0
fi

# === Validate array index ===
if [ "$SLURM_ARRAY_TASK_ID" -ge "${#filenames[@]}" ]; then
    echo "? Invalid array index: $SLURM_ARRAY_TASK_ID"
    exit 1
fi

filename="${filenames[$SLURM_ARRAY_TASK_ID]}"
variable="${variables[$SLURM_ARRAY_TASK_ID]}"

echo "?? Task [$SLURM_ARRAY_TASK_ID] Merging Started at $(date)"
echo "?? Processing file: $filename with variable: $variable"

module restore scimods
source ~/virtual-envs/scienv/bin/activate

# Run Python and suppress HDF5 warnings by redirecting stderr
python3 2>/dev/null <<EOF
import os, re, glob, importlib, time
import xarray as xr
import dask

start_time = time.time()

os.environ["HDF5_USE_FILE_LOCKING"] = "FALSE"
os.environ["HDF5_DISABLE_VERSION_CHECK"] = "1"
dask.config.set(scheduler="threads")

variable = "${variable}"
filename = "${filename}"
input_dir = "/scratch/zelalem/CanTrans-models/subbasin_MESH_run/MESH_${FORCING}/${GRU}/mesh_lss"
output_dir = "/scratch/zelalem/CanTrans-models/subbasin_MESH_run/MESH_${FORCING}/${GRU}/mesh_lss"
output_file = os.path.join(output_dir, f"merged_{filename}")

engine = "netcdf4"  # Force netcdf4 to avoid HDF5 attribute issues
print(f"?? Using engine: {engine}")

def extract_start_id(path):
    match = re.search(r'Run_(\d+)_to_(\d+)', path)
    return int(match.group(1)) if match else float('inf')

files = sorted(glob.glob(f"{input_dir}/**/OBASINAVG/{filename}", recursive=True), key=extract_start_id)
files = [f for f in files if os.path.getsize(f) > 1000]

if not files:
    raise RuntimeError(f"? No valid files found for merging: {filename}")

offset = 0
datasets = []
for path in files:
    try:
        ds = xr.open_dataset(path, chunks={"time": 10000}, decode_times=False, decode_cf=False)
        if "subbasin" not in ds.dims:
            raise ValueError(f"'subbasin' dimension missing in {path}")
        sub_len = ds.sizes["subbasin"]
        ds = ds.assign_coords(subbasin=ds["subbasin"] + offset)
        print(f"{path} ? subbasin offset: {offset} ? range: {offset} to {offset + sub_len - 1}")
        offset += sub_len
        datasets.append(ds)
    except Exception as e:
        print(f"?? Skipping file due to error: {path}")
        print(f"   Error: {e}")

if not datasets:
    raise RuntimeError("? No datasets could be loaded successfully.")

stitched = xr.concat(datasets, dim="subbasin", data_vars="minimal", coords="minimal", compat="override")

if "time" in stitched.variables:
    stitched["time"].attrs["units"] = datasets[0]["time"].attrs.get("units")
    stitched["time"].attrs["calendar"] = datasets[0]["time"].attrs.get("calendar", "standard")

encoding = {}
for var in stitched.data_vars:
    dims = stitched[var].dims
    shape = stitched[var].shape
    dtype = stitched[var].dtype
    chunks = tuple(10000 if d == "time" else shape[i] for i, d in enumerate(dims))
    encoding[var] = {
        "chunksizes": chunks,
        "dtype": dtype.name
    }

stitched.to_netcdf(output_file, format="NETCDF4", unlimited_dims=["time"], encoding=encoding)
print(f"? Merge complete: {output_file}")
print(f"? Completed in {time.time() - start_time:.2f} seconds.")
EOF

echo "?? Task [$SLURM_ARRAY_TASK_ID] Merging Complete at $(date)"
