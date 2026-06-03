#!/bin/bash
#SBATCH --job-name=pipeline
#SBATCH --account=rrg-alpie
#SBATCH --time=00:05:00
#SBATCH --mem=1G
#SBATCH --output=logs_CMIP6/pipeline_%j.out
#SBATCH --error=logs_CMIP6/pipeline_%j.err

SCENARIO="ssp585"  # or "historical"
BASE_DIR="/project/6102189/sujata1/easymore_outputs/${SCENARIO}"
OUT_DIR="${BASE_DIR}/compiled"
mkdir -p "$OUT_DIR" logs_CMIP6

# === Stage 1: Merge + Leap per variable ===
VARS=(rsds tas huss rlds ps pr uas vas)
LEAP_JOBS=()

for VAR in "${VARS[@]}"; do
  J=$(sbatch --parsable --export=VAR=${VAR},BASE_DIR=${BASE_DIR},OUT_DIR=${OUT_DIR} merge_and_leap.sh)
  LEAP_JOBS+=($J)
  echo "🚀 Submitted merge+leap for $VAR → Job $J"
done

# === Stage 2: Wind speed (after uas+vas) ===
UAS_JOB=${LEAP_JOBS[-2]}
VAS_JOB=${LEAP_JOBS[-1]}
UV_JOB=$(sbatch --parsable --dependency=afterok:${UAS_JOB}:${VAS_JOB} --export=OUT_DIR=${OUT_DIR} calc_uv_from_merged.sh)
echo "💨 Submitted UV calculation → Job $UV_JOB"

# === Stage 3: Final merge (after all) ===
ALL_DEPS=$(IFS=:; echo "${LEAP_JOBS[*]}:$UV_JOB")
FINAL_JOB=$(sbatch --parsable --dependency=afterok:${ALL_DEPS} --export=OUT_DIR=${OUT_DIR} final_merge.sh)
echo "🧩 Submitted final merge → Job $FINAL_JOB"

echo "📊 Pipeline launched for scenario: $SCENARIO"
