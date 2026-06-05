#!/bin/bash
#SBATCH --job-name=unit_convert
#SBATCH --output=logs/unit_casr_%A_%a.out
#SBATCH --error=logs/unit_casr_%A_%a.err
#SBATCH --account=rrg-alpie
#SBATCH --array=0-149
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=02:30:00

### Load required modules and virtual environment
module restore scimods
source ~/virtual-envs/scienv/bin/activate

mkdir -p logs

# Run embedded Python
python3 - <<EOF
import os
import subprocess

FILES_PER_TASK = 6 # The number of file per array (in this case: 899 / 150)
TASK_ID = int(os.environ.get("SLURM_ARRAY_TASK_ID", 0))

INPUT_DIR = '/project/6102189/zelalem/era5l-nc-nhs-extract'
TEMP_DIR = '/project/6102189/zelalem/era5land-datatool-outputs_withunit'
os.makedirs(TEMP_DIR, exist_ok=True)

FAILED_LOG = os.path.join(TEMP_DIR, f'failed_unit_conversion_{TASK_ID}.txt')

input_files = sorted([
    os.path.join(INPUT_DIR, f)
    for f in os.listdir(INPUT_DIR)
    if f.endswith('.nc')
])

start_index = TASK_ID * FILES_PER_TASK
end_index = min(start_index + FILES_PER_TASK, len(input_files))

# Unit updates
unit_updates = {
    "p": "mm s-1",
}

cdo_expr = "p = p / 3600"

selected_vars = ",".join([
    "p","ssrd","strd",
    "sp","q","t2m",
    "wind_speed","u10",
    "v10"
])

for i in range(start_index, end_index):
    input_file = input_files[i]
    filename = os.path.basename(input_file)
    output_file = os.path.join(TEMP_DIR, f"{filename}")

    print(f"🔧 Converting units: {filename}")

    try:
        # Update units in input file
        for var, unit in unit_updates.items():
            subprocess.run([
                "ncatted", "-O",
                "-a", f"units,{var},o,c,{unit}",
                input_file
            ], check=True)

        # Apply arithmetic and variable selection
        subprocess.run([
            "cdo", "-s", "-L", "-f", "nc4c", "-z", "zip",
            "-aexpr," + cdo_expr,
            f"-select,name={selected_vars}",
            input_file, output_file
        ], check=True)

        # -----------------------------
        # NEW SECTION ADDED
        # -----------------------------

        # Convert time from seconds to hours
        subprocess.run([
            "ncap2", "-O",
            "-s", "time=time/3600.0",
            output_file, output_file
        ], check=True)

        # Add missing standard_name attributes
        subprocess.run([
            "ncatted", "-O",
            "-a", "standard_name,sp,o,c,surface_air_pressure",
            "-a", "standard_name,p,o,c,precipitation_amount",
            "-a", "standard_name,ssrd,o,c,surface_downwelling_shortwave_flux",
            "-a", "standard_name,strd,o,c,surface_downwelling_longwave_flux",
            "-a", "standard_name,u10,o,c,eastward_wind",
            "-a", "standard_name,v10,o,c,northward_wind",
            "-a", "standard_name,t2m,o,c,air_temperature",
            output_file
        ], check=True)

        print(f"✅ Unit conversion complete: {filename}")

    except Exception as e:
        print(f"❌ Unit conversion failed: {filename} — {e}")
        with open(FAILED_LOG, 'a') as f:
            f.write(input_file + "\n")
EOF