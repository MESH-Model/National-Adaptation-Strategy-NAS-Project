#!/bin/bash
#SBATCH --account=hpc_c_giws_pomeroy
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --mem=128G
#SBATCH --time=10:00:00
#SBATCH --job-name=CanTrans
#SBATCH --error=errors_CanTrans
##
module load cdo
module load nco
##
#cdo monsum -selname,RDRS_v2.1_A_PR0_SFC MESH_input_CanTrans_CaSR_1980_2018.nc tmp.nc && cdo -select,startdate=1980-10-01,enddate=1984-09-30 tmp.nc PREC_M_GRD.nc
#cdo chname,RDRS_v2.1_A_PR0_SFC,PREC PREC_M_GRD.nc tmp.nc && tmp.nc PREC_M_GRD.nc
##
# Define the list of variables
vars="RDRS_v2.1_P_P0_SFC RDRS_v2.1_A_PR0_SFC RDRS_v2.1_P_TT_09944 RDRS_v2.1_P_UVC_09944 RDRS_v2.1_P_HU_09944 RDRS_v2.1_P_FB_SFC RDRS_v2.1_P_FI_SFC"

# Loop over each variable in the list
for var in $vars
do
  # Extract the variable into a new file
  cdo selvar,$var MESH_input_CanTrans_CaSR_1980_2018.nc ${var}_extracted.nc
  
  # Get information about the new file
  cdo info ${var}_extracted.nc > ${var}.txt
  
  # Optionally, remove the extracted file after getting information
  rm ${var}_extracted.nc
done

