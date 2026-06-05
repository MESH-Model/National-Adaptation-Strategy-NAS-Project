#!/bin/bash
#SBATCH --job-name=cdo_chunked
#SBATCH --output=logs3/output_%A_%a.out
#SBATCH --error=logs3/error_%A_%a.err
#SBATCH --account=rpp-kshook
#SBATCH --array=0-149
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=8000M
#SBATCH --time=00:59:00


### load the required modules and set the virtual environment 
module restore scimods
source ~/virtual-envs/scienv/bin/activate

echo "Running SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID"

PYTHON_SCRIPT=$(mktemp)

cat << EOF > $PYTHON_SCRIPT
import xarray as xr
import numpy as np

job_index = $SLURM_ARRAY_TASK_ID

# File paths
#output_ddb_nc = '/scratch/zelalem/CanTrans-models/MESH_model_run/out_MESH_drainage_database.nc'
input_climate_nc = f'/scratch/zelalem/CanTrans-models/easymore-outputs/batches_CaSRv3p1/batch_{job_index}.nc'
output_climate_nc = f'/scratch/zelalem/CanTrans-models/easymore-outputs/temp_v3p1/batch_CaSRv3p1_{job_index}.nc'

# Load datasets
#with xr.open_dataset(input_climate_nc, chunks={}) as data_nc, xr.open_dataset(output_ddb_nc) as mask_nc:
with xr.open_dataset(input_climate_nc, chunks={}) as data_nc:
    # Step 1: Sort data_nc by ID
    data_ids = data_nc["ID"].values
    sort_idx = np.argsort(data_ids)
    data_sorted = data_nc.isel(subbasin=sort_idx)
    data_sorted.to_netcdf(output_climate_nc)
    
#    # Step 2: Get Rank_old and convert to 0-based index
#    rank = mask_nc["Rank_old"].values.astype(int)
#    valid = rank > 0
#    rank = rank[valid]
#    mask_ids = rank - 1  # These are the positional indices in data_sorted

#    # Step 3: Subset data using sorted Rank_old order
#    subset = data_sorted.isel(subbasin=xr.DataArray(mask_ids, dims="subbasin"))

#    # Step 4: Assign correct coordinates from mask file
#    subset = subset.assign_coords({
#        "ID": subset["ID"],
#        "latitude": subset["latitude"],
#        "longitude": subset["longitude"]
#    })   
    
    # Step 5: Save
#    subset.to_netcdf(output_climate_nc)

print(f"Processed and saved: {output_climate_nc}")
EOF

python $PYTHON_SCRIPT

rm $PYTHON_SCRIPT
