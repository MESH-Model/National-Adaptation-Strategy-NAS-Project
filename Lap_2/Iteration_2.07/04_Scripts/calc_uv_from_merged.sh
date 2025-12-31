#!/bin/bash
#SBATCH --job-name=calc_uv
#SBATCH --account=rrg-alpie
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --output=logs_CMIP6/uv_%j.out
#SBATCH --error=logs_CMIP6/uv_%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=sujata.budhathoki@usask.ca

module restore scimods
set -euo pipefail

OUT_DIR=${OUT_DIR:?}
#OUT_DIR="/project/6102189/sujata1/easymore_outputs/ssp585/compiled"
cd "$OUT_DIR"

UAS="tmp_uas_leapfixed.nc"
VAS="tmp_vas_leapfixed.nc"
UV_OUT="tmp_uvs_leapfixed.nc"

if [[ -f "$UV_OUT" ]]; then
  echo "⏭️  UVS already exists → skipping"
  exit 0
fi

echo "💨 Calculating wind speed (uvs) from UAS + VAS..."

# Step 1: Compute UV magnitude
cdo -O -L -sqrt -add -sqr -selname,uas "$UAS" -sqr -selname,vas "$VAS" tmp_uv_raw.nc

# Step 2: Rename variable from 'uas' to 'uvs'
cdo -O chname,uas,uvs tmp_uv_raw.nc tmp_uvs.nc

# Step 3: Add metadata to uvs
ncatted -O \
  -a standard_name,uvs,o,c,"wind_speed" \
  -a long_name,uvs,o,c,"Near-surface Wind Speed (from uas and vas)" \
  -a units,uvs,o,c,"m s-1" \
  tmp_uvs.nc

# Step 4: Standardize calendar
cdo -O setcalendar,standard tmp_uvs.nc tmp_uvs_std.nc

mv tmp_uvs_std.nc "$UV_OUT"

# Step 6: Clean up temporary files
#rm -f tmp_uv_raw.nc tmp_uvs.nc tmp_uvs_std.nc
echo "✅ Wind speed (uvs) complete → $UV_OUT"
