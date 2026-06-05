#!/bin/bash
set -euo pipefail

# ------------------------
# 🔧 USER CONFIGURATIONS
# ------------------------
domain="remapped_remapped_era5l"
start_year=1950
end_year=2024

# Variables to spatially fill (time, subbasin)
# Add any others present in your files. Leave empty string to auto-detect.
fill_vars="p q sp ssrd strd t2m wind_speed, u10, v10"

# Missing value fallback if _FillValue is not present
missing_value="-9999.0"

# Spatial options
wrap_dateline="1"   # 1 = wrap longitudes; 0 = do not wrap
chunk_size="20000"  # time chunk size for spatial filler; 0 = load all

# Input/output directories
daily_input_dir="/home/test/scratch/cantrans-models/era5land-easymore-outputs"
yearly_output_dir="/home/test/scratch/cantrans-models/era5land-easymore-outputs/easymore-outputs-yearly"
final_output_dir="/home/test/scratch/cantrans-models/era5l"

mkdir -p "$yearly_output_dir" "$final_output_dir" "logs_era5l"

# ------------------------
# 📜 SCRIPT PATHS
# ------------------------
daily_script="merge_daily_array.sh"
final_script="merge_yearly_final.sh"

# ------------------------
# 🧱 Generate the yearly array job script
#     - Merge daily -> yearly
#     - Conditionally run spatial fill (only if missing exists)
# ------------------------
cat > "$daily_script" <<'EOF'
#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=mergeDailyArray
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH --output=logs_era5l/merge_daily_%A_%a.out
#SBATCH --error=logs_era5l/merge_daily_%A_%a.err

set -euo pipefail

# Load required modules (Compute Canada style).
# Adjust versions if your site uses versioned modules (e.g., python/3.11).
module load cdo
module load nco
module load python

# --- CONFIG (passed via --export) ---
DOMAIN="${DOMAIN:-remapped_remapped_era5l}"
DAILY_INPUT_DIR="${DAILY_INPUT_DIR:-/path/to/daily}"
YEARLY_OUTPUT_DIR="${YEARLY_OUTPUT_DIR:-/path/to/yearly}"

FILL_VARS="${FILL_VARS:-p q}"
MISSING_VALUE="${MISSING_VALUE:--9999.0}"
WRAP_DATELINE="${WRAP_DATELINE:-1}"   # 1 wrap, 0 no wrap
CHUNK="${CHUNK:-20000}"

# Optional: names for dims/coords (override via --export if different)
TIME_DIM="${TIME_DIM:-time}"
SUB_DIM="${SUB_DIM:-subbasin}"
LAT_VAR="${LAT_VAR:-latitude}"
LON_VAR="${LON_VAR:-longitude}"

year="$SLURM_ARRAY_TASK_ID"
output_file="${YEARLY_OUTPUT_DIR}/${DOMAIN}.${year}.nc"

echo "▶️  Year ${year}"
files=$(find "${DAILY_INPUT_DIR}" -maxdepth 1 -type f -name "${DOMAIN}.${year}*.nc" | sort || true)
if [ -z "$files" ]; then
  echo "⚠️  No daily files found for year ${year}"
  exit 1
fi
echo "🔎 Found $(echo "$files" | wc -l) daily files."

# Optional attribute fixes (keep if your sources need them)
ncatted -O \
  -a standard_name,sp,a,c,"surface_air_pressure" \
  -a standard_name,p,a,c,"precipitation_amount" \
  -a standard_name,ssrd,a,c,"surface_downwelling_shortwave_flux" \
  -a standard_name,strd,a,c,"surface_downwelling_longwave_flux" \
  -a standard_name,u10,a,c,"eastward_wind" \
  -a standard_name,v10,a,c,"northward_wind" \
  -a standard_name,t2m,a,c,"air_temperature" \
  $files

# Safe time conversion (seconds -> hours) file-by-file
echo "⏱️  Converting time seconds → hours on daily files"
for f in $files; do
  tmp="${f%.nc}.tmp.nc"
  ncap2 -O -s 'time=time/3600.0' "$f" "$tmp"
  mv -f "$tmp" "$f"
  ncatted -O -a units,time,o,c,"hours since 1950-02-01T00:00:00" "$f"
done

# Merge -> yearly file
echo "🔄 Merging daily files → $output_file"
cdo -f nc4c -z zip -b F32 mergetime $files "$output_file"
echo "✅ Year ${year} merged: $output_file"

# -----------------------------------------------
# 🧭 CONDITIONAL SPATIAL FILL (inline Python)
#   - Skips automatically if no missing values.
#   - Uses 'easy' nearest: |Δlat| + |Δlon| (optional wrap).
# -----------------------------------------------

export OUTPUT_FILE="$output_file"
export FILL_VARS="$FILL_VARS"
export MISSING_VALUE="$MISSING_VALUE"
export WRAP_DATELINE="$WRAP_DATELINE"
export CHUNK="$CHUNK"
export TIME_DIM="$TIME_DIM"
export SUB_DIM="$SUB_DIM"
export LAT_VAR="$LAT_VAR"
export LON_VAR="$LON_VAR"

python3 - <<'PYCODE'
import os, sys, numpy as np
from netCDF4 import Dataset

fn = os.environ['OUTPUT_FILE']
fill_vars = os.environ.get('FILL_VARS', '').split()
miss_fallback = float(os.environ.get('MISSING_VALUE', '-9999.0'))
wrap = os.environ.get('WRAP_DATELINE', '1') not in ('0','false','False','NO','no')
chunk = int(os.environ.get('CHUNK','20000'))
time_dim = os.environ.get('TIME_DIM','time')
sub_dim  = os.environ.get('SUB_DIM','subbasin')
lat_name = os.environ.get('LAT_VAR','latitude')
lon_name = os.environ.get('LON_VAR','longitude')

def lon_diff(lon_i, lon_all, wrap):
    d = np.abs(lon_all - lon_i)
    if wrap:
        d = np.minimum(d, 360.0 - d)
    return d

def build_order(lat, lon, wrap):
    S = lat.size
    orders = []
    for i in range(S):
        dlat = np.abs(lat - lat[i])
        dlon = lon_diff(lon[i], lon, wrap)
        dL1 = dlat + dlon
        ord_i = np.argsort(dL1, kind='stable')
        orders.append(ord_i[ord_i != i])
    return orders

def detect_vars(ds, time_dim, sub_dim, lat_name, lon_name):
    out = []
    for name, v in ds.variables.items():
        if name in (lat_name, lon_name): continue
        if v.ndim == 2 and v.dimensions == (time_dim, sub_dim) and np.issubdtype(v.dtype, np.floating):
            out.append(name)
    return out

def fill_chunk_inplace(block, donor_orders):
    # Block is a masked array (if _FillValue/missing_value present).
    if not isinstance(block, np.ma.MaskedArray):
        block = np.ma.MaskedArray(block, mask=np.zeros(block.shape, dtype=bool))
    nan_mask = np.isnan(block.data)
    if nan_mask.any():
        block.mask = np.logical_or(block.mask, nan_mask)

    miss = np.ma.getmaskarray(block)
    if not miss.any():
        return 0

    T, S = block.shape
    total = 0
    for i in range(S):
        remaining = miss[:, i].copy()
        if not remaining.any(): continue
        for j in donor_orders[i]:
            donor_valid = ~np.ma.getmaskarray(block[:, j])
            can = remaining & donor_valid
            if not can.any(): continue
            block.data[can, i] = block.data[can, j]
            if block.mask is not np.ma.nomask:
                block.mask[can, i] = False
            total += int(can.sum())
            remaining &= ~can
            if not remaining.any(): break
    return total

ds = Dataset(fn, 'r+')
ds.set_auto_maskandscale(True)

# Basic checks
if lat_name not in ds.variables or lon_name not in ds.variables:
    print("ℹ️  Missing latitude/longitude — skipping spatial fill.")
    ds.close(); sys.exit(0)
if time_dim not in ds.dimensions or sub_dim not in ds.dimensions:
    print("ℹ️  Missing time/subbasin dims — skipping spatial fill.")
    ds.close(); sys.exit(0)

lat = ds.variables[lat_name][:].astype(np.float64)
lon = ds.variables[lon_name][:].astype(np.float64)
if wrap:
    lon = np.mod(lon, 360.0)

T = ds.dimensions[time_dim].size

# Variables: ensure _FillValue exists BEFORE reading any data so masking is applied
var_names = fill_vars if fill_vars else detect_vars(ds, time_dim, sub_dim, lat_name, lon_name)
if not var_names:
    print("ℹ️  No eligible (time,subbasin) float variables — skipping fill.")
    ds.close(); sys.exit(0)

for vname in var_names:
    v = ds.variables.get(vname)
    if v is None: continue
    if not hasattr(v, "_FillValue"):
        try:
            v.setncattr("_FillValue", miss_fallback)
        except Exception:
            pass

# Quick probe: check for missing via mask; if none, skip
has_missing = False
for vname in var_names:
    v = ds.variables.get(vname)
    if v is None or v.ndim != 2 or v.dimensions != (time_dim, sub_dim): continue
    step = max(1, T // 10)  # probe ~10 chunks
    for t0 in range(0, T, step):
        t1 = min(T, t0 + step)
        blk = v[t0:t1, :]
        if int(np.ma.count_masked(blk)) > 0:
            has_missing = True
            break
    if has_missing: break

if not has_missing:
    print("🟢 No missing values detected — skipping spatial fill.")
    ds.close(); sys.exit(0)

# Proceed with spatial fill
donor_orders = build_order(lat, lon, wrap)
chunk = T if chunk <= 0 else chunk
grand_total = 0

for vname in var_names:
    v = ds.variables.get(vname)
    if v is None:
        print(f"Skipping '{vname}' (not in file).")
        continue
    if v.ndim != 2 or v.dimensions != (time_dim, sub_dim):
        print(f"Skipping '{vname}' (expected (time, subbasin)).")
        continue

    filled_var = 0
    for t0 in range(0, T, chunk):
        t1 = min(T, t0 + chunk)
        blk = v[t0:t1, :]  # masked array
        before = int(np.ma.count_masked(blk))
        filled = fill_chunk_inplace(blk, donor_orders)
        after = int(np.ma.count_masked(blk))
        v[t0:t1, :] = blk
        filled_var += filled
        print(f"  {vname} chunk {t0}:{t1} — missing before: {before}, after: {after}, filled: {filled}")

    grand_total += filled_var
    print(f"Variable '{vname}': filled {filled_var} values via spatial NN.")

ds.close()
print(f"✅ Spatial fill complete. Total filled values: {grand_total}")
PYCODE

echo "✅ Year ${year} processing complete: ${output_file}"
EOF

chmod +x "$daily_script"

# ------------------------
# 🧱 Generate the final merge script
# ------------------------
cat > "$final_script" <<'EOF'
#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=finalMerge
#SBATCH --mem=128G
#SBATCH --time=23:00:00
#SBATCH --output=logs_era5l/final_merge.out
#SBATCH --error=logs_era5l/final_merge.err

set -euo pipefail

# Load required modules for final merge too
module load cdo
module load nco
module load python

DOMAIN="${DOMAIN:-remapped_remapped_era5l}"
YEARLY_OUTPUT_DIR="${YEARLY_OUTPUT_DIR:-/path/to/yearly}"
FINAL_OUTPUT_DIR="${FINAL_OUTPUT_DIR:-/path/to/final}"
START_YEAR="${START_YEAR:-1950}"
END_YEAR="${END_YEAR:-2024}"

merged_file="${FINAL_OUTPUT_DIR}/${DOMAIN}.${START_YEAR}_${END_YEAR}_forcing.nc"
yearly_files=$(find "${YEARLY_OUTPUT_DIR}" -type f -name "${DOMAIN}.*.nc" | sort || true)
if [ -z "$yearly_files" ]; then
  echo "⚠️  No yearly files found to merge."
  exit 1
fi

echo "🔄 Merging all yearly files into final file..."
cdo -f nc4c -z zip -b F32 mergetime $yearly_files "$merged_file"
echo "✅ Final merged file created: $merged_file"
EOF

chmod +x "$final_script"

# ------------------------
# 🚀 Submit jobs
# ------------------------
export_daily="ALL,DOMAIN=${domain},DAILY_INPUT_DIR=${daily_input_dir},YEARLY_OUTPUT_DIR=${yearly_output_dir},FILL_VARS=${fill_vars},MISSING_VALUE=${missing_value},WRAP_DATELINE=${wrap_dateline},CHUNK=${chunk_size}"
export_final="ALL,DOMAIN=${domain},YEARLY_OUTPUT_DIR=${yearly_output_dir},FINAL_OUTPUT_DIR=${final_output_dir},START_YEAR=${start_year},END_YEAR=${end_year}"

jid=$(sbatch --parsable --array=${start_year}-${end_year} --export="$export_daily" "$daily_script")
echo "📨 Submitted array job with ID: $jid"

sbatch --dependency=afterok:$jid --export="$export_final" "$final_script" >/dev/null
echo "🧵 Final merge job will run after the array completes successfully."