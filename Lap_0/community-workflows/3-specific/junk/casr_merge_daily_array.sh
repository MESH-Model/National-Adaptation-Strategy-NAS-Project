#!/bin/bash
#SBATCH --account=rrg-alpie
#SBATCH --job-name=mergeDailyArray
#SBATCH --array=1980-1980
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --output=logs_casr/merge_daily_%A_%a.out
#SBATCH --error=logs_casr/merge_daily_%A_%a.err

module load cdo
module load nco

year=$SLURM_ARRAY_TASK_ID
output_file="/home/zelalem/scratch/cantrans-models/merit-casr3p2-easymore-outputs/easymore-outputs-yearly/remapped_remapped_casr_${year}.nc"

files=$(find "/home/zelalem/scratch/cantrans-models/merit-casr3p2-easymore-outputs" -maxdepth 1 -type f -name "remapped_remapped_casr_${year}*.nc" | sort)
#files=$(find "/home/zelalem/scratch/cantrans-models/merit-casr3p2-easymore-outputs" -type f -name "remapped_remapped_casr_${year}*.nc" | sort)

if [ -z "$files" ]; then
    echo "? No daily files found for year $year"
    exit 1
fi

echo "?? Merging daily files for year $year..."
cdo -f nc4c -z zip -b F32 mergetime $files "$output_file"
echo "? Year $year merged: $output_file"
