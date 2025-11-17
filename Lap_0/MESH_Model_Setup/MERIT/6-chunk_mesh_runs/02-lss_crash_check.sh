#!/bin/bash

## Case-1 ##
# # Script to extract last 5 lines from all model_lss.log files
# # inside Run_* directories under the specified parent path
# set -euo pipefail
# # Hardcoded parent directory
# #PARENT_DIR="${1:-.}"
# PARENT_DIR="/scratch/zelalem/CanTrans-models/subbasin_MESH_run/MESH_CaSRv3p1/Average_GRU_Params/mesh_lss_2/"

# # Find all model_lss.log files inside Run_* directories
# find "$PARENT_DIR" -type f -name "model_lss.log" | grep "/Run_[^/]\+/" | sort | while read -r logfile; do
  # echo "===== File: $logfile ====="
  # tail -n 5 "$logfile"
  # echo
# done


## Case-2 ##
# Code to check the crash runs from all runs
#grep -i "failed" /scratch/zelalem/CanTrans-models/subbasin_MESH_run/MESH_CaSRv3p1/Average_GRU_Params/mesh_lss/logs/output_*.log > dist_failed_lines.txt




## Case-3 ##
# Script to extract lines around "Abnormal exit" from model_lss.log files

set -euo pipefail

# Hardcoded parent directory
PARENT_DIR="/scratch/zelalem/CanTrans-models/subbasin_MESH_run/MESH_CaSRv3p1/Distributed_GRU_Params/mesh_lss/"

# Find all model_lss.log files inside Run_* directories
find "$PARENT_DIR" -type f -name "model_lss.log" | grep "/Run_[^/]\+/" | sort | while read -r logfile; do
  # Check if the log contains "Abnormal exit"
  if grep -q "Abnormal exit" "$logfile"; then
    echo "===== File: $logfile ====="
    
    # Print 4 lines above + the "Abnormal exit" line (i.e., total of 5 lines)
    # Use awk for flexible control
    awk '
    {
      lines[NR % 5] = $0  # Circular buffer of last 5 lines
    }
    /Abnormal exit/ {
      print "--- Matched at line " NR " ---"
      for (i=NR-4; i<=NR; i++) {
        idx = i % 5
        if (idx == 0) idx = 5
        print lines[idx]
      }
      print ""
    }
    ' "$logfile"
  fi
done
