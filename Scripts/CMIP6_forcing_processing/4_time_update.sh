#!/bin/bash
#SBATCH --job-name=merge_fix_netcdf
#SBATCH --account=rrg-alpie
#SBATCH --time=05:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=1
#SBATCH --output=logs_merge/output_%j.out
#SBATCH --error=logs_merge/error_%j.err

module load cdo nco
set -euo pipefail

# Directory with files
WORKDIR="/project/6102189/sujata1/easymore_outputs/ssp370/compiled"
cd "$WORKDIR"

# Output filenames
MERGED_FILE="merged_all_tmp.nc"
FINAL_FILE="merged_all_final.nc"

# Variables to merge
FILES=(
  tmp_huss_leapfixed.nc
  tmp_pr_leapfixed.nc
  tmp_ps_leapfixed.nc
  tmp_rlds_leapfixed.nc
  tmp_rsds_leapfixed.nc
  tmp_tas_leapfixed.nc
  tmp_uvs_leapfixed.nc
)

echo "🔹 Merging variables..."
cdo -O merge "${FILES[@]}" "$MERGED_FILE"

echo "🔹 Setting time axis..."
cdo -O settaxis,2015-01-01,01:00:00,1hour "$MERGED_FILE" "$FINAL_FILE"

echo "🔹 Removing extra latitude/longitude variables..."
cdo -O delvar,latitude_2,longitude_2,latitude_3,longitude_3,latitude_4,longitude_4,latitude_5,longitude_5,latitude_6,longitude_6 "$FINAL_FILE" "$FINAL_FILE"

# Cleanup temporary file
rm -f "$MERGED_FILE"

echo "✅ All done: $FINAL_FILE"
ls -lh "$FINAL_FILE"
