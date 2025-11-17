#!/bin/bash

# ------------------------
# ?? USER CONFIGURATIONS
# ------------------------
domain="remapped_remapped_casr"
start_year=1979
end_year=2023

# Input/output directories
daily_input_dir="/home/zelalem/scratch/cantrans-models/casr-easymore-outputs"
yearly_output_dir="/home/zelalem/scratch/cantrans-models/casr-easymore-outputs/easymore-outputs-yearly"
final_output_dir="/home/zelalem/scratch/cantrans-models/casr"

mkdir -p "$yearly_output_dir" "$final_output_dir" "logs_casr"

# ------------------------
# ?? SCRIPT PATHS
# ------------------------
daily_script="casr_merge_daily_array.sh"
final_script="casr_merge_yearly_final.sh"

# ------------------------
# ?? Generate daily merge (array job) script
# ------------------------
cat > "$daily_script" <<EOF
#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=mergeDailyArray
#SBATCH --array=${start_year}-${end_year}
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --output=logs_casr/merge_daily_%A_%a.out
#SBATCH --error=logs_casr/merge_daily_%A_%a.err

module load cdo
module load nco

year=\$SLURM_ARRAY_TASK_ID
output_file="${yearly_output_dir}/${domain}_\${year}.nc"

files=\$(find "${daily_input_dir}" -type f -name "${domain}_\${year}*.nc" | sort)

if [ -z "\$files" ]; then
    echo "? No daily files found for year \$year"
    exit 1
fi

echo "?? Merging daily files for year \$year..."
cdo -f nc4c -z zip -b F32 mergetime \$files "\$output_file"
echo "? Year \$year merged: \$output_file"
EOF

chmod +x "$daily_script"

# ------------------------
# ?? Generate final merge script
# ------------------------
cat > "$final_script" <<EOF
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

merged_file="${final_output_dir}/${domain}_${start_year}_${end_year}_forcing.nc"
yearly_files=\$(find "${yearly_output_dir}" -type f -name "${domain}_*.nc" | sort)

if [ -z "\$yearly_files" ]; then
    echo "? No yearly files found to merge."
    exit 1
fi

echo "?? Merging all yearly files into final file..."
cdo -f nc4c -z zip -b F32 mergetime \$yearly_files "\$merged_file"
echo "? Final merged file created: \$merged_file"
EOF

chmod +x "$final_script"

# ------------------------
# ?? Submit jobs
# ------------------------

# Submit array job for yearly merges
#jid=$(sbatch --parsable "$daily_script")
#echo "?? Submitted array job with ID: $jid"

# Submit final merge after array completes
sbatch --dependency=afterok:$jid "$final_script"
echo "?? Final merge job submitted (after array completes successfully)"

# Optional: clean up temporary scripts
# rm -f "$daily_script" "$final_script"