#!/bin/bash

INPUT_DIR="/scratch/zelalem/cantrans-models/rdrs-datatool-outputs2"
OUTPUT_DIR="/scratch/zelalem/cantrans-models/rdrs-easymore-outputs"

# List input files (just filenames)
ls "$INPUT_DIR"/*.nc | xargs -n 1 basename | sort > input_files.txt

# List output files, remove 'pre_' prefix, then sort
ls "$OUTPUT_DIR"/*.nc | xargs -n 1 basename | sed 's/^remapped_remapped_//' | sort > output_files.txt

# Find files in input_files.txt not in output_files.txt
comm -23 input_files.txt output_files.txt > missing_files.txt

echo "Missing files (present in input but no converted output):"
cat missing_files.txt

# To diagnose easymore crashes by reading easymore output log
#awk 'FNR==1{print FILENAME ": " $0}' cache{1980..2018}/easymore.err 2>/dev/null > bb_summary.txt

# Check each file for the subbasin dimension and print if any file that has subbasin less or greater than 77017
for f in *.nc; do c=$(ncdump -h "$f" | grep -Eo "subbasin = [0-9]+" | awk '{print $3}'); [[ "$c" != "77017" ]] && echo " Removing $f (subbasin=$c)" && rm -f "$f"; done
