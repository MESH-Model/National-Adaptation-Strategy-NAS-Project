#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=finalMerge
#SBATCH --account=rrg-alpie
#SBATCH --mem=128G
#SBATCH --time=23:00:00
#SBATCH --output=logs_era5l/final_merge.out
#SBATCH --error=logs_era5l/final_merge.err

module load cdo
module load nco

merged_file="/home/zelalem/scratch/cantrans-models/era5l/remapped_remapped_era5l.1950_2024_forcing.nc"
yearly_files=$(find "/home/zelalem/scratch/cantrans-models/era5land-easymore-outputs/easymore-outputs-yearly" -type f -name "remapped_remapped_era5l.*.nc" | sort)

if [ -z "$yearly_files" ]; then
    echo "? No yearly files found to merge."
    exit 1
fi

echo "?? Merging all yearly files into final file..."
cdo -f nc4c -z zip -b F32 mergetime $yearly_files "$merged_file"
echo "? Final merged file created: $merged_file"
