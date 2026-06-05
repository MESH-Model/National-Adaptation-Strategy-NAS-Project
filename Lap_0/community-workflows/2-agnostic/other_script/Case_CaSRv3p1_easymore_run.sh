#!/bin/bash
#SBATCH --job-name=easymore_array
#SBATCH --array=0 #-149  # Adjust to total/FILES_PER_TASK
#SBATCH --output=logs_CaSRv3p1/output_%A_%a.out
#SBATCH --error=logs_CaSRv3p1/error_%A_%a.err
#SBATCH --time=02:58:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --account=rrg-alpie

# Load required modules and virtual environment
module restore scimods
source ~/virtual-envs/scienv/bin/activate

# Run embedded Python
python3 - <<'END'
import os, sys, subprocess
#from easymore import Easymore
from easymore.easymore import easymore

# Constants
FILES_PER_TASK = 108
TASK_ID = int(os.environ.get("SLURM_ARRAY_TASK_ID", 0))

INPUT_DIR = '/scratch/zelalem/cantrans-models/casr-datatool-outputs2'
OUTPUT_DIR = '/scratch/zelalem/cantrans-models/casr-easymore-outputs/'
TEMP_DIR = os.path.join(OUTPUT_DIR, 'cache/')
SHAPEFILE = '/home/zelalem/github-repos/community-workflows/1-geofabric/CanTrans-merit-geofabric/sorted_agg_MERIT_CanTrans_subbasins.shp'
REMAPPING_NC = os.path.join(TEMP_DIR, 'remapped_remapping.nc')
SHAPEFILE_ID = "Rank"
DIMENSION_ID = "subbasin"

# Ensure cache directory exists
os.makedirs(TEMP_DIR, exist_ok=True)

# Load input files
input_files = sorted([os.path.join(INPUT_DIR, f) for f in os.listdir(INPUT_DIR) if f.endswith('.nc')])
start_index = TASK_ID * FILES_PER_TASK
end_index = min(start_index + FILES_PER_TASK, len(input_files))

# Unit conversions and expressions
unit_updates = {
    "CaSR_v3.1_A_PR0_SFC": "mm s-1",
    "CaSR_v3.1_P_PR0_SFC": "mm s-1",
    "CaSR_v3.1_P_TT_09975": "K",
    "CaSR_v3.1_P_P0_SFC": "Pa",
    "CaSR_v3.1_P_HU_09975": "kg/kg",
    "CaSR_v3.1_P_UVC_09975": "m s-1",
    "CaSR_v3.1_P_UUC_09975": "m s-1",
    "CaSR_v3.1_P_VVC_09975": "m s-1",
}
cdo_expr = (
    "CaSR_v3.1_A_PR0_SFC = CaSR_v3.1_A_PR0_SFC / 3.6;"
    "CaSR_v3.1_P_PR0_SFC = CaSR_v3.1_P_PR0_SFC / 3.6;"
    "CaSR_v3.1_P_TT_09975 = CaSR_v3.1_P_TT_09975 + 273.15;"
    "CaSR_v3.1_P_P0_SFC = CaSR_v3.1_P_P0_SFC * 100.0;"
    "CaSR_v3.1_P_UVC_09975 = CaSR_v3.1_P_UVC_09975 * 0.51444444444444;"
    "CaSR_v3.1_P_UUC_09975 = CaSR_v3.1_P_UUC_09975 * 0.51444444444444;"
    "CaSR_v3.1_P_VVC_09975 = CaSR_v3.1_P_VVC_09975 * 0.51444444444444"	
)
selected_vars = ",".join([
    "CaSR_v3.1_A_PR0_SFC","CaSR_v3.1_P_FB_SFC","CaSR_v3.1_P_FI_SFC",
    "CaSR_v3.1_P_P0_SFC","CaSR_v3.1_P_HU_09975","CaSR_v3.1_P_TT_09975",
    "CaSR_v3.1_P_UVC_09975","CaSR_v3.1_P_PR0_SFC","CaSR_v3.1_P_UUC_09975",
    "CaSR_v3.1_P_VVC_09975"
])

for i in range(start_index, end_index):
    input_file = input_files[i]
    filename = os.path.basename(input_file)
    preprocessed_file = os.path.join(TEMP_DIR, f"{filename}")
    case_name = "remapped"
    print(f"?? Preprocessing: {filename}")

    # Skip if output already exists
    expected_output = os.path.join(OUTPUT_DIR, f"{case_name}_{filename}")
    if os.path.exists(expected_output):
        print(f"? Skipping (already processed): {expected_output}")
        continue

    # Step 1: Update units using ncatted
    for var, unit in unit_updates.items():
        subprocess.run(["ncatted", "-O", "-a", f"units,{var},o,c,{unit}", input_file], check=True)

    # Step 2: Run CDO arithmetic and select variables
    cdo_cmd = [
        "cdo", "-s", "-L", "-f", "nc4c", "-z", "zip",
        "-aexpr," + cdo_expr,
        f"-select,name={selected_vars}",
        input_file, preprocessed_file
    ]
    subprocess.run(cdo_cmd, check=True)

    # Step 3: Remap using EASYMORE
    print(f"???  Remapping: {preprocessed_file}")
#    esmr = Easymore()
    esmr = easymore()
    esmr.case_name = case_name
    esmr.temp_dir = TEMP_DIR
    esmr.target_shp = SHAPEFILE
    esmr.target_shp_ID = SHAPEFILE_ID
    esmr.source_nc = preprocessed_file
    esmr.var_names = selected_vars.split(",")
    esmr.var_lon = "lon"
    esmr.var_lat = "lat"
    esmr.var_time = "time"
    esmr.remapped_var_id = DIMENSION_ID
    esmr.remapped_dim_id = DIMENSION_ID
    esmr.output_dir = OUTPUT_DIR
    esmr.format_list = ["f4"]
    esmr.fill_value_list = ["-9999.00"]
    esmr.complevel = 9
    #esmr.remap_nc = REMAPPING_NC
    #esmr.save_csv = True

    try:
        esmr.nc_remapper()
    except Exception as e:
        print(f"? Error processing {filename}: {e}")
        sys.exit(1)
    finally:
        # Optional: Clean up temporary file
        if os.path.exists(preprocessed_file):
            os.remove(preprocessed_file)
            print(f"?? Removed temp: {preprocessed_file}")

END
