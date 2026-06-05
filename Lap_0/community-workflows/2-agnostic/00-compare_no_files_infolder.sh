#!/bin/bash

INPUT_DIR="/project/6102189/data/meteorological-data/casrv3.2"
OUTPUT_DIR="/scratch/zelalem/cantrans-models/clrh-casr3p2-easymore-outputs"  #merit-casr3p2-easymore-outputs"   #clrh-casr3p2-easymore-outputs" #casr3p2-datatool-outputs_withunit" #casr3p2-datatool-outputs"

# List input files (just filenames)
ls "$INPUT_DIR"/*.nc | xargs -n 1 basename | sort > input_files.txt

# List output files, remove 'pre_' prefix, then sort
#ls "$OUTPUT_DIR"/*.nc | xargs -n 1 basename | sed 's/^casr_//' | sort > output_files.txt
ls "$OUTPUT_DIR"/*.nc | xargs -n 1 basename | sed 's/^remapped_remapped_casr_//' | sort > output_files.txt

# Find files in input_files.txt not in output_files.txt
comm -23 input_files.txt output_files.txt > missing_files.txt

# To diagnose easymore crashes by reading easymore output log
#awk 'FNR==1{print FILENAME ": " $0}' cache*/easymore.err > bb_summary2.txt 2>/dev/null

# Check each file for the subbasin dimension and print if any file that has subbasin less or greater than 77017
#for f in *.nc; do c=$(ncdump -h "$f" | grep -Eo "subbasin = [0-9]+" | awk '{print $3}'); [[ "$c" != "77017" ]] && echo " Removing $f (subbasin=$c)" && rm -f "$f"; done