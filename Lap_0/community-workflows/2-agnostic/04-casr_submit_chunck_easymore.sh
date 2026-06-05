#!/bin/bash

### Load required modules and virtual environment
module restore scimods
source ~/virtual-envs/scienv/bin/activate

# Copy remapping file
cp -r /scratch/zelalem/cantrans-models/camels-casr3p2-easymore-outputs/cache_org /scratch/zelalem/cantrans-models/camels-casr3p2-easymore-outputs/cache_cli

# Start and End date
StartYear=1979
EndYear=2024     # Adjust the end year as needed

# Use a for loop to iterate over the range of years
for (( kk = StartYear; kk <= EndYear; kk++ ))
do
# Change directory to the specified path
cd /home/zelalem/github-repos/community-workflows/2-agnostic 
    
# Copy template JSON file to a new file
#cp 04-merit-casr-easymore-model-agnostic.json easymore-model-agnostic.json
#cp 04-clrh-casr-easymore-model-agnostic.json easymore-model-agnostic.json
cp 04-camels-casr-easymore-model-agnostic.json easymore-model-agnostic.json

    
# Modify the new JSON file with sed, replacing DATATOOLFOLDER with $kk
sed -i -e "s|DATAFOLDER|$kk|g" easymore-model-agnostic.json
sed -i -e "s|CACHEFOLDER|cache$kk|g" easymore-model-agnostic.json
    
# Optionally, if you want to uncomment and run a script (remove the '#' at the beginning)
./model-agnostic.sh easymore-model-agnostic.json
done