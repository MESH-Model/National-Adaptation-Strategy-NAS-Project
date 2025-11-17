#!/bin/bash
#SBATCH --job-name=unit_convert
#SBATCH --output=logs/unit_casr_%A_%a.out
#SBATCH --error=logs/unit_casr_%A_%a.err
#SBATCH --account=rrg-alpie
#SBATCH --array=0-149
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:30:00

### Load required modules and virtual environment
module restore scimods
source ~/virtual-envs/scienv/bin/activate

mkdir -p logs

# Run embedded Python
python3 - <<EOF
import os
import subprocess

FILES_PER_TASK = 108
TASK_ID = int(os.environ.get("SLURM_ARRAY_TASK_ID", 0))

INPUT_DIR = '/scratch/zelalem/cantrans-models/casr-datatool-outputs'
TEMP_DIR = '/scratch/zelalem/cantrans-models/casr-datatool-outputs2'
os.makedirs(TEMP_DIR, exist_ok=True)

# Path to log failed files for this task
FAILED_LOG = os.path.join(TEMP_DIR, f'failed_unit_conversion_{TASK_ID}.txt')

input_files = sorted([
    os.path.join(INPUT_DIR, f)
    for f in os.listdir(INPUT_DIR)
    if f.endswith('.nc')
])

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
