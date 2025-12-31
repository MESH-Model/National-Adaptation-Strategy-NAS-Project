#!/bin/bash
#SBATCH --job-name=merge_leap
#SBATCH --account=rrg-alpie
#SBATCH --time=05:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=1
#SBATCH --output=logs_CMIP6/merge_%x_%A_%a.out
#SBATCH --error=logs_CMIP6/merge_%x_%A_%a.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=sujata.budhathoki@usask.ca

module restore scimods
set -euo pipefail

VAR=${VAR:?}
BASE_DIR=${BASE_DIR:?}
OUT_DIR=${OUT_DIR:?}
mkdir -p "$OUT_DIR"

OUT="${OUT_DIR}/tmp_${VAR}_leapfixed.nc"

if [[ -f "$OUT" ]]; then
  echo "⏭️  $VAR already leap-fixed → skipping"
  exit 0
fi

WORKDIR="${SLURM_TMPDIR:-${OUT_DIR}/tmp_${VAR}_$$}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

TMP="tmp_${VAR}.nc"
echo "🔄 Merging + leap-fixing $VAR in $WORKDIR"

FILES=()
for f in ${BASE_DIR}/remapped_remap_remapped_${VAR}_*.nc; do
  ncdump -k "$f" >/dev/null 2>&1 && FILES+=("$f") || echo "⚠️ Skipping broken: $f"
done
if [ ${#FILES[@]} -eq 0 ]; then
  echo "❌ No valid files found for $VAR"
  exit 1
fi

cdo -O -L mergetime "${FILES[@]}" "$TMP"
cdo -O setcalendar,standard "$TMP" tmp_std_${VAR}.nc
YEARS=$(cdo showyear tmp_std_${VAR}.nc | tr " " "\n" | sort -u)

LEAPS=()
is_leap(){ (( ($1%4==0 && $1%100!=0) || $1%400==0 )); }

for y in $YEARS; do
  is_leap "$y" || continue
  echo "🗓️  Adding Feb 29 for $VAR $y"
  cdo -O -L -selhour,0/23 -selday,28 -selmon,2 -selyear,$y tmp_std_${VAR}.nc feb28_${y}.nc
  cdo -O -L -selhour,0/23 -selday,1  -setmon,3 -selyear,$y tmp_std_${VAR}.nc mar1_${y}.nc
  cdo -O -L -setday,29 -setmon,2 -divc,2 -add feb28_${y}.nc mar1_${y}.nc leap_${VAR}_${y}.nc
  LEAPS+=("leap_${VAR}_${y}.nc")
  rm -f feb28_${y}.nc mar1_${y}.nc
done

if [ ${#LEAPS[@]} -gt 0 ]; then
  cdo -O -L mergetime tmp_std_${VAR}.nc "${LEAPS[@]}" "$OUT"
  rm -f "${LEAPS[@]}"
else
  cp tmp_std_${VAR}.nc "$OUT"
fi


echo "✅ Finished $VAR → $OUT"
