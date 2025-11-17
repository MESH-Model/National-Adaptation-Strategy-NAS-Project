#!/bin/bash
#SBATCH --job-name=unit_convert
#SBATCH --output=logs/unit_rdrs_%A_%a.out
#SBATCH --error=logs/unit_rdrs_%A_%a.err
#SBATCH --account=rrg-alpie
#SBATCH --array=0-149
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:30:00


# Load modules or activate your environment
module load cdo nco python  # or conda activate your-env

# Run embedded Python
python3 - <<EOF
import os
import subprocess
import glob

FILES_PER_TASK = 108
TASK_ID = int(os.environ.get("SLURM_ARRAY_TASK_ID", 0))

INPUT_DIR = '/scratch/zelalem/cantrans-models/rdrs-datatool-outputs'
TEMP_DIR = '/scratch/zelalem/cantrans-models/rdrs-datatool-outputs2'
os.makedirs(TEMP_DIR, exist_ok=True)

# Path to log failed files for this task
FAILED_LOG = os.path.join(TEMP_DIR, f'failed_unit_conversion_{TASK_ID}.txt')

INPUT_DIR = '/scratch/zelalem/cantrans-models/rdrs-datatool-outputs'
INPUT_PATTERN = os.path.join(INPUT_DIR, '**', '*.nc')
input_files = sorted(glob.glob(INPUT_PATTERN, recursive=True))

start_index = TASK_ID * FILES_PER_TASK
end_index = min(start_index + FILES_PER_TASK, len(input_files))

# Unit conversions and expressions
unit_updates = {
    "RDRS_v2.1_A_PR0_SFC": "mm s-1",
    "RDRS_v2.1_P_PR0_SFC": "mm s-1",
    "RDRS_v2.1_P_TT_09944": "K",
    "RDRS_v2.1_P_P0_SFC": "Pa",
    "RDRS_v2.1_P_HU_09944": "kg/kg",
    "RDRS_v2.1_P_UVC_09944": "m s-1",
    "RDRS_v2.1_P_UUC_09944": "m s-1",
    "RDRS_v2.1_P_VVC_09944": "m s-1",
}
cdo_expr = (
    "RDRS_v2.1_A_PR0_SFC = RDRS_v2.1_A_PR0_SFC / 3.6;"
    "RDRS_v2.1_P_PR0_SFC = RDRS_v2.1_P_PR0_SFC / 3.6;"
    "RDRS_v2.1_P_TT_09944 = RDRS_v2.1_P_TT_09944 + 273.15;"
    "RDRS_v2.1_P_P0_SFC = RDRS_v2.1_P_P0_SFC * 100.0;"
    "RDRS_v2.1_P_UVC_09944 = RDRS_v2.1_P_UVC_09944 * 0.51444444444444;"
    "RDRS_v2.1_P_UUC_09944 = RDRS_v2.1_P_UUC_09944 * 0.51444444444444;"
    "RDRS_v2.1_P_VVC_09944 = RDRS_v2.1_P_VVC_09944 * 0.51444444444444"	
)
selected_vars = ",".join([
    "RDRS_v2.1_A_PR0_SFC","RDRS_v2.1_P_FB_SFC","RDRS_v2.1_P_FI_SFC",
    "RDRS_v2.1_P_P0_SFC","RDRS_v2.1_P_HU_09944","RDRS_v2.1_P_TT_09944",
    "RDRS_v2.1_P_UVC_09944","RDRS_v2.1_P_PR0_SFC","RDRS_v2.1_P_UUC_09944",
    "RDRS_v2.1_P_VVC_09944"
])

for i in range(start_index, end_index):
    input_file = input_files[i]
    filename = os.path.basename(input_file)
    output_file = os.path.join(TEMP_DIR, f"{filename}")
    print(f"🔧 Converting units: {filename}")

    try:
        # Update units using ncatted
        for var, unit in unit_updates.items():
            subprocess.run(["ncatted", "-O", "-a", f"units,{var},o,c,{unit}", input_file], check=True)

        # Apply arithmetic using cdo
        subprocess.run([
            "cdo", "-s", "-L", "-f", "nc4c", "-z", "zip",
            "-aexpr," + cdo_expr,
            f"-select,name={selected_vars}",
            input_file, output_file
        ], check=True)

        print(f"✅ Unit conversion complete: {filename}")

    except Exception as e:
        print(f"❌ Unit conversion failed: {filename} — {e}")
        # Log the failed file path
        with open(FAILED_LOG, 'a') as f:
            f.write(input_file + "\n")
EOF
