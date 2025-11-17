#!/bin/sh
#SBATCH --account=hpc_c_giws_pomeroy
#SBATCH --nodes=12
#SBATCH --ntasks-per-node=32
#SBATCH --mem=128G
#SBATCH --time=160:00:00
#SBATCH --job-name=CanTrans
#SBATCH --error=errors_CanTrans
#
ln -sf /datastore/Hydrology/hydrology_staff/Zel/CanTrans_MESH_model/MESH_input_CanTrans_CaSR_1980_2018.nc MESH_input_CanTrans_CaSR_1980_2018.nc
#
MESH_MPI=/globalhome/zkt451/HPC/MESH_Code/r1860_ME_ZT/junk/mpi_sa_mesh_old
srun $MESH_MPI