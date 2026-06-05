#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=finalMerge
#SBATCH --account=rrg-alpie
#SBATCH --mem=128G
#SBATCH --time=12:00:00
#SBATCH --output=logs_casr/final_merge.out
#SBATCH --error=logs_casr/final_merge.err

module load cdo
module load nco

merged_file="/home/zelalem/scratch/cantrans-models/merit_casr3p2/remapped_remapped_casr_1980_1980_forcing.nc"
yearly_files=$(find "/home/zelalem/scratch/cantrans-models/merit-casr3p2-easymore-outputs/easymore-outputs-yearly" -type f -name "remapped_remapped_casr_*.nc" | sort)

if [ -z "$yearly_files" ]; then
    echo "? No yearly files found to merge."
    exit 1
fi

echo "?? Merging all yearly files into final file..."
cdo -f nc4c -z zip -b F32 mergetime $yearly_files "$merged_file"
echo "? Final merged file created: $merged_file"
