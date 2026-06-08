#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=finalMerge
#SBATCH --mem=64G
#SBATCH --time=6:58:00
#SBATCH --output=logs/final_merge.out
#SBATCH --error=logs/final_merge.err

module load cdo
module load nco

yearly_files=$(find "/scratch/zelalem/cantrans-models/Calibration/AllCalibration/easymore-outputs-yearly" -type f -name "remapped_remapped_casr_*.nc" | sort)
merged_file="/scratch/zelalem/cantrans-models/Calibration/AllCalibration/easymore-outputs-yearly/MESH_forcing_cal_camels_casr3p2_1979_2024.nc"

if [ -z "$yearly_files" ]; then
    echo "? No yearly files found to merge."
    exit 1
fi

echo "?? Merging all yearly files into final file..."
cdo -f nc4c -z zip -b F32 mergetime $yearly_files "$merged_file"
echo "? Final merged file created: $merged_file"
