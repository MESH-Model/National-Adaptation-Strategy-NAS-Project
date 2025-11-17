#!/bin/bash
#SBATCH --account=def-kshook
#SBATCH --job-name=merge_subbasin_array
#SBATCH --output=logs/merge_%A_%a.out
#SBATCH --error=logs/merge_%A_%a.err
#SBATCH --array=0 #-2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=05:59:00

module restore scimods
source ~/virtual-envs/scienv/bin/activate

# Define filename-variable pairs
declare -a filenames=("RFF_H_GRD.nc")
declare -a variables=("RFF")

#declare -a filenames=("RFF_D_GRD.nc" "ET_H_GRD.nc" "RFF_H_GRD.nc")
#declare -a variables=("RFF" "ET" "RFF")

# Get the filename and variable for this array task
filename=${filenames[$SLURM_ARRAY_TASK_ID]}
variable=${variables[$SLURM_ARRAY_TASK_ID]}

echo "🔄 Processing file: $filename with variable: $variable"

python3 <<EOF
import os, re, glob, importlib, dask, time
import xarray as xr

start_time = time.time()

# Safety settings
os.environ["HDF5_USE_FILE_LOCKING"] = "FALSE"
os.environ["HDF5_DISABLE_VERSION_CHECK"] = "1"
dask.config.set(scheduler="threads")

# Configuration
variable = "${variable}"
filename = "${filename}"
input_dir = "/scratch/zelalem/CanTrans-models/subbasin_MESH_run/MESH_CaSRv3p1/Distributed_GRU_Params/mesh_lss"
output_dir = "/scratch/zelalem/CanTrans-models/subbasin_MESH_run/MESH_CaSRv3p1/Distributed_GRU_Params"
output_file = os.path.join(output_dir, f"merged_{filename}")

# Choose engine
engine = "h5netcdf" if importlib.util.find_spec("h5netcdf") else "netcdf4"
print(f"? Using engine: {engine}")

def extract_start_index(p):
    m = re.search(r'_(\\d+)_to_\\d+', p)
    return int(m.group(1)) if m else float('inf')

files = sorted(glob.glob(f"{input_dir}/**/OBASINAVG/{filename}", recursive=True),
               key=extract_start_index)

print(f"?? Found {len(files)} files before filtering.")
files = [f for f in files if os.path.getsize(f) > 1000]
print(f"? {len(files)} files passed size check.")

if not files:
    raise RuntimeError(f"? No valid files found for merging: {filename}")

def preprocess(ds):
    if variable in ds.data_vars:
        return ds[[variable]]
    else:
        raise KeyError(f"Variable '{variable}' not found in dataset. Available variables: {list(ds.data_vars)}")

ds = xr.open_mfdataset(
    files,
    combine='nested',
    concat_dim='subbasin',
    engine=engine,
    parallel=True,
    chunks={"time": 10000},
    preprocess=preprocess
)

ds = ds.chunk({'subbasin': 512, 'time': 10000})

comp = dict(zlib=True, complevel=4)
encoding = {var: comp for var in ds.data_vars}

ds.to_netcdf(output_file, engine=engine, encoding=encoding, compute=True)

end_time = time.time()
duration = end_time - start_time
print(f"? Merge complete: {output_file}")
print(f"?? Completed in {duration:.2f} seconds.")
EOF