#!/bin/bash
#SBATCH --account=def-kshook
#SBATCH --job-name=split_casr_netcdf
#SBATCH --output=split_casr_%A_%a.out
#SBATCH --error=split_casr_%A_%a.err
#SBATCH --time=23:00:00                     # Adjust after benchmarking
#SBATCH --cpus-per-task=4                   # Use more CPUs for multithreaded ncks
#SBATCH --mem=16G                           # Adjust based on chunk size and test runs
#SBATCH --array=0-148                       # (total_subbasins / chunk_size) - 1

# Load required module
module load nco

# Set number of threads for ncks (uses OpenMP)
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Configuration
input_file="remapped_casr_forcing_1979_2023.nc"
chunk_size=520
total_subbasins=77017
output_dir="./subbasin_forcing_CaSRv3p1"
mkdir -p "$output_dir"

# Calculate chunk range for this array task
task_id=${SLURM_ARRAY_TASK_ID}
start_idx=$((task_id * chunk_size))
end_idx=$((start_idx + chunk_size - 1))

# Clamp end_idx to total_subbasins - 1
if [ "$end_idx" -ge "$total_subbasins" ]; then
    end_idx=$((total_subbasins - 1))
fi

# Output file
output_file="${output_dir}/MESH_forcing_subbasin_${start_idx}_to_${end_idx}.nc"

# Skip if file already exists (safe to rerun)
if [[ -f "$output_file" ]]; then
    echo "File $output_file already exists. Skipping..."
    exit 0
fi

# Run the slicing with compression and buffer tuning
echo "Processing subbasins $start_idx to $end_idx with $OMP_NUM_THREADS threads"
ncks --buffer_size=268435456 -O -h -L 6 -d subbasin,"$start_idx","$end_idx" "$input_file" "$output_file"

echo "Created $output_file"




