#!/bin/bash
# === Load environment ===
#module load python
module restore scimods
source ~/virtual-envs/scienv/bin/activate

# === Embedded Python ===
python3 - <<EOF
import xarray as xr
import numpy as np

# === File paths ===
file1 = "/gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/subbasin_MESH_run/subbasin_master/MESH_drainage_database.nc"  # Replace with your original file
file2 = "/gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/subbasin_MESH_run/MESH_CaSRv3p1/Average_GRU_Params/merged3_RFF_D_GRD.nc"    # Replace with your merged file

# === Load datasets ===
ds1 = xr.open_dataset(file1)
ds2 = xr.open_dataset(file2)

# === Coordinates to compare ===
coords = ["lat", "lon"]

for coord in coords:
    print(f"\n?? Comparing coordinate: {coord}")

    if coord not in ds1 or coord not in ds2:
        print(f"? Missing '{coord}' in one of the files.")
        continue

    arr1 = ds1[coord].values
    arr2 = ds2[coord].values

    if arr1.shape != arr2.shape:
        print(f"? Shape mismatch: {arr1.shape} vs {arr2.shape}")
        continue

    if np.allclose(arr1, arr2, equal_nan=True):
        print("? Values match.")
    else:
        print("?? Values differ. Showing first few mismatches:")
        diffs = np.where(~np.isclose(arr1, arr2, equal_nan=True))[0]
        for i in diffs[:10]:
            print(f"  Index {i}: file1={arr1[i]}, file2={arr2[i]}")
        print(f"... {len(diffs)} total mismatches")

print("\n? Comparison complete.")

EOF