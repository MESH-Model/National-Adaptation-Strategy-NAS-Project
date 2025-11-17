#!/bin/bash
#SBATCH --account=hpc_c_giws_pomeroy
#SBATCH --job-name=split_big_netcdf
#SBATCH --output=split_bigfile_%j.out
#SBATCH --error=split_bigfile_%j.err
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24             # Controls number of parallel jobs
#SBATCH --mem=128G                     # Adjust based on chunk size

module load nco

# Input NetCDF file
input_file="CanTrans_CaSRv3p1_MESH_forcing.nc"
# Chunk size
chunk_size=512
# Total number of subbasins
total_subbasins=72508
# Number of parallel jobs (adjust based on system resources)
num_jobs=24

# Function to process a chunk
process_chunk() {
    start_idx=$1
    end_idx=$2
    output_file="MESH_forcing_subbasin_${start_idx}_to_${end_idx}.nc"
    ncks -O -h -d subbasin,${start_idx},${end_idx} $input_file $output_file
    echo "Created $output_file"
}

# Export the function and variables for GNU Parallel
export -f process_chunk
export input_file

# Calculate number of chunks
num_chunks=$(( (total_subbasins + chunk_size - 1) / chunk_size ))

# Generate start and end indices for each chunk
for ((i=0; i<num_chunks; i++)); do
    start_idx=$((i * chunk_size))
    end_idx=$((start_idx + chunk_size - 1))
    if [ $end_idx -ge $total_subbasins ]; then
        end_idx=$((total_subbasins - 1))
    fi
    echo "$start_idx $end_idx"
done | parallel -j $num_jobs --colsep ' ' process_chunk {1} {2}