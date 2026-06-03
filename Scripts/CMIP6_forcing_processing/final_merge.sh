#!/bin/bash
#SBATCH --job-name=final_merge
#SBATCH --account=rrg-alpie
#SBATCH --time=04:00:00
#SBATCH --mem=100G
#SBATCH --output=logs_CMIP6/final_merge_%j.out
#SBATCH --error=logs_CMIP6/final_merge_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sujata.budhathoki@usask.ca

module restore scimods
set -euo pipefail

OUT_DIR=${OUT_DIR:?}
cd "$OUT_DIR"

FINAL="${OUT_DIR}/merged_all_final.nc"
if [[ -f "$FINAL" ]]; then
  echo "⏭️  Final merged file exists → skipping"
  exit 0
fi

FILES=(tmp_rsds_leapfixed.nc tmp_tas_leapfixed.nc tmp_huss_leapfixed.nc \
       tmp_rlds_leapfixed.nc tmp_ps_leapfixed.nc tmp_pr_leapfixed.nc \
       tmp_uvs_leapfixed.nc)

echo "📦 Merging ${#FILES[@]} variables..."
cdo -O -L merge "${FILES[@]}" "$FINAL"

echo "✅ Final merged output: $FINAL"

# === Completion summary ===
SUMMARY="${OUT_DIR}/summary_report_$(date +%Y%m%d_%H%M).txt"
{
  echo "===== CMIP6 MERGE SUMMARY ====="
  echo "Date: $(date)"
  echo "Scenario: $(basename "$(dirname "$OUT_DIR")")"
  echo
  echo "Merged files:"
  du -h "${FILES[@]}" | sort -h
  echo
  echo "Final merged file:"
  du -h "$FINAL"
  echo
  echo "Line count of time dimension:"
  ncdump -v time "$FINAL" | grep -c "time ="
  echo
  echo "Completed successfully on node: $(hostname)"
} > "$SUMMARY"

echo "📧 Sending completion summary to email..."
mail -s "✅ CMIP6 Final Merge Completed [$(basename "$(dirname "$OUT_DIR")")]" \
     sujata.budhathoki@usask.ca < "$SUMMARY"

echo "📄 Summary saved → $SUMMARY"
