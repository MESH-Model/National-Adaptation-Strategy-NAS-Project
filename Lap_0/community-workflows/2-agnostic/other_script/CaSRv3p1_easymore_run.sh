#!/bin/bash
#SBATCH --job-name=easymore_array
#SBATCH --array=0 #-149
#SBATCH --output=logs_CaSRv3p1/output_%A_%a.out
#SBATCH --error=logs_CaSRv3p1/error_%A_%a.err
#SBATCH --time=01:30:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --account=rrg-alpie

### Load required modules and virtual environment
module restore scimods
source ~/virtual-envs/scienv/bin/activate

# Run embedded Python
python3 - <<'END'
import os, glob, sys
from easymore import Easymore

# Constants
FILES_PER_TASK = 108
TASK_ID = int(os.environ.get("SLURM_ARRAY_TASK_ID", 0))

INPUT_DIR = '/scratch/zelalem/cantrans-models/casr-datatool-outputs'
OUTPUT_DIR = '/scratch/zelalem/cantrans-models/casr-easymore-outputs/'
TEMP_DIR = os.path.join(OUTPUT_DIR, 'cache/')
SHAPEFILE='/home/zelalem/github-repos/community-workflows/1-geofabric/CanTrans-merit-geofabric/sorted_agg_MERIT_CanTrans_subbasins.shp'
#REMAPPING_CSV = os.path.join(OUTPUT_DIR, 'cache//remapped_remapping_file_2099e65ab432f0abd5cc5a78c9e16737d9ebd71a273d9221744a7c66d391f428.csv')
#REMAPPING_NC = os.path.join(OUTPUT_DIR, 'cache//remapped_remapping.nc')

# Load input files
input_files = sorted([os.path.join(INPUT_DIR, f) for f in os.listdir(INPUT_DIR) if f.endswith('.nc')])
start_index = TASK_ID * FILES_PER_TASK
end_index = min(start_index + FILES_PER_TASK, len(input_files))

# Process assigned files
for i in range(start_index, end_index):
    input_file = input_files[i]
    case_name = "remapped"
    print(f"?? Processing: {input_file}")

    #esmr = easymore()
    esmr = Easymore()
    esmr.case_name = case_name
    esmr.temp_dir = TEMP_DIR
    esmr.target_shp = SHAPEFILE
    esmr.target_shp_ID = "Rank"
    esmr.source_nc = input_file
    esmr.var_names = [
	'CaSR_v3.1_A_PR0_SFC','CaSR_v3.1_P_FB_SFC','CaSR_v3.1_P_FI_SFC',
	'CaSR_v3.1_P_P0_SFC','CaSR_v3.1_P_HU_09975','CaSR_v3.1_P_TT_09975',
	'CaSR_v3.1_P_UVC_09975','CaSR_v3.1_P_PR0_SFC','CaSR_v3.1_P_VVC_09975',
	'CaSR_v3.1_P_UUC_09975'
	]
    esmr.var_lon = "lon"
    esmr.var_lat = "lat"
    esmr.var_time = "time"
    esmr.remapped_var_id = "subbasin"
    esmr.remapped_dim_id = "subbasin"
    esmr.output_dir = OUTPUT_DIR
    esmr.format_list = ["f4"]
    esmr.fill_value_list = ["-9999.00"]
    esmr.complevel = 9
    esmr.save_csv = True
    #esmr.remap_csv = REMAPPING_CSV
    #esmr.remap_nc = REMAPPING_NC

    try:
        esmr.nc_remapper()
    except Exception as e:
        print(f"Error processing {input_file}: {e}")
        sys.exit(1)
END