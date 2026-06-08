#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=merge_master
#SBATCH --output=logs/merge_master.out
#SBATCH --error=logs/merge_master.err

# ---------------------------
# Configuration
# ---------------------------
input_dir="/home/zelalem/scratch/cantrans-models/clrh-casr3p2-easymore-outputs/easymore-outputs-yearly"
work_dir="/home/zelalem/scratch/cantrans-models/clrh-casr3p2/intermediate_merges"
final_file="/home/zelalem/scratch/cantrans-models/clrh-casr3p2/intermediate_merges/remapped_remapped_casr_1979_2024_forcing.nc"

mkdir -p $work_dir
mkdir -p logs

# ---------------------------
# Create array job script dynamically
# ---------------------------
array_script="merge_chunks_array_temp.sh"

cat << 'EOF' > $array_script
#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=merge_chunks
#SBATCH --output=logs/merge_chunks_%A_%a.out
#SBATCH --error=logs/merge_chunks_%A_%a.err
#SBATCH --array=1-5
#SBATCH --time=12:00:00
#SBATCH --mem=64G

module load cdo
module load nco

input_dir="INPUT_DIR_REPLACE"
work_dir="WORK_DIR_REPLACE"

# Define year ranges
start_years=("1979" "1990" "2000" "2010" "2020")
end_years=("1989" "1999" "2009" "2019" "2024")

index=$((SLURM_ARRAY_TASK_ID - 1))
start_year=${start_years[$index]}
end_year=${end_years[$index]}

chunk_file="$work_dir/chunk_${start_year}_${end_year}.nc"

echo "Processing years $start_year-$end_year -> $chunk_file"

# Merge files for this chunk
cdo -f nc4c -z zip -b F32 mergetime $(ls $input_dir/remapped_remapped_casr_${start_year}*.nc $input_dir/remapped_remapped_casr_${end_year:0:3}*.nc 2>/dev/null) $chunk_file

echo "Chunk created: $chunk_file"
EOF

# Replace placeholders with actual directories
sed -i "s|INPUT_DIR_REPLACE|$input_dir|g" $array_script
sed -i "s|WORK_DIR_REPLACE|$work_dir|g" $array_script

# ---------------------------
# Submit array job and get its job ID
# ---------------------------
array_job_id=$(sbatch --parsable $array_script)
echo "Array job submitted with ID: $array_job_id"

# ---------------------------
# Create final merge job script dynamically
# ---------------------------
final_script="merge_final_temp.sh"

cat << 'EOF' > $final_script
#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=merge_final
#SBATCH --output=logs/merge_final.out
#SBATCH --error=logs/merge_final.err
#SBATCH --time=24:00:00
#SBATCH --mem=128G

module load cdo
module load nco

work_dir="WORK_DIR_REPLACE"
final_file="FINAL_FILE_REPLACE"

echo "Merging all intermediate chunks..."

cdo -f nc4c -z zip -b F32 mergetime $work_dir/chunk_*.nc $final_file

echo "Final merged file created: $final_file"
EOF

# Replace placeholders
sed -i "s|WORK_DIR_REPLACE|$work_dir|g" $final_script
sed -i "s|FINAL_FILE_REPLACE|$final_file|g" $final_script

# ---------------------------
# Submit final merge job with dependency on array completion
# ---------------------------
sbatch --dependency=afterok:$array_job_id $final_script
echo "Final merge job submitted, will run after array job completes."