#!/bin/bash
#SBATCH --job-name=easymore_array
#SBATCH --array=0#-2 #-149
#SBATCH --output=logs_CaSRv2p1/output_%A_%a.out
#SBATCH --error=logs_CaSRv2p1/error_%A_%a.err
#SBATCH --time=00:30:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --account=def-kshook

# Load required modules
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3
module load gdal/3.5.1 libspatialindex/1.8.5
module load python/3.8.10 scipy-stack/2022a mpi4py/3.0.3

# Activate your Python virtual environment
source ~/easymore-env/bin/activate

# Run embedded Python
python3 - <<'END'
import os, sys
from easymore.easymore import easymore

# Constants
FILES_PER_TASK = 108
TASK_ID = int(os.environ.get("SLURM_ARRAY_TASK_ID", 0))

INPUT_DIR = '/project/6006250/zelalem/Test' #   '/scratch/zelalem/CanTrans-models/CaSRv2p1/MESH_CaSRv2p1'
OUTPUT_DIR = '/scratch/zelalem/CanTrans-models/easymore-outputs/CaSRv2p1/'
TEMP_DIR = os.path.join(OUTPUT_DIR, 'cache/')
SHAPEFILE = '/home/zelalem/github-repos/MESH-CanTrans/1-geofabric/MERIT-CanTrans-geofabric/agg_MERIT_CanTrans_subbasins.shp'
REMAPPING_CSV = os.path.join(OUTPUT_DIR, 'cache/remapped_remapping.csv')

# Load input files
input_files = sorted([os.path.join(INPUT_DIR, f) for f in os.listdir(INPUT_DIR) if f.endswith('.nc')])
start_index = TASK_ID * FILES_PER_TASK
end_index = min(start_index + FILES_PER_TASK, len(input_files))

# Process assigned files
for i in range(start_index, end_index):
    input_file = input_files[i]
    case_name = "remapped"
    print(f"🔄 Processing: {input_file}")
    esmr = easymore()
    esmr.case_name = case_name
    esmr.temp_dir = TEMP_DIR
    esmr.target_shp = SHAPEFILE
    esmr.target_shp_ID = "Rank"
    esmr.source_nc = input_file
#    esmr.var_names = [
#        'RDRS_v2.1_P_P0_SFC','RDRS_v2.1_P_HU_09944','RDRS_v2.1_P_TT_09944',
#        'RDRS_v2.1_A_PR0_SFC','RDRS_v2.1_P_FB_SFC','RDRS_v2.1_P_FI_SFC',
#        'RDRS_v2.1_P_UVC_09944','RDRS_v2.1_P_UUC_09944','RDRS_v2.1_P_VVC_09944'
#    ]
    esmr.var_names = [
        'CaSR_v3.1_P_P0_SFC','CaSR_v3.1_P_HU_09975','CaSR_v3.1_P_TT_09975',
        'CaSR_v3.1_A_PR0_SFC','CaSR_v3.1_P_FB_SFC','CaSR_v3.1_P_FI_SFC',
        'CaSR_v3.1_P_UVC_09975','CaSR_v3.1_P_UUC_09975','CaSR_v3.1_P_VVC_09975'
    ]
    esmr.var_lon = "lon"
    esmr.var_lat = "lat"
    esmr.var_time = "time"
    esmr.remapped_var_id = "subbasin"
    esmr.remapped_dim_id = "subbasin"
    esmr.format_list = ["f4"]
    esmr.fill_value_list = [-9999.00]
    esmr.complevel = 9
    esmr.save_csv = True
    esmr.output_dir = OUTPUT_DIR
    # esmr.remap_csv = REMAPPING_CSV
    # esmr.only_create_remap_nc = True
    
    try:
        esmr.nc_remapper()
    except Exception as e:
        print(f"❌ Error processing {input_file}: {e}")
        sys.exit(1)
END