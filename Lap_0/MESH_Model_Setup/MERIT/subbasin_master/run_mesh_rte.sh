#!/bin/bash
#SBATCH --account=def-kshook
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=23:59:00
#SBATCH --job-name=CaSRv3p1_MESH_Run
#SBATCH --error=errors_CaSRv3p1
#
MESH_MPI=/home/zelalem/MESH_Code/MESH-Dev-SA_MESH_1.5-SA_MESH_1.5.5/mpi_sa_mesh
#MESH_MPI=/scratch/zelalem/CanTrans-models/r1860_ME_ZT/mpi_sa_mesh

#export OMP_NUM_THREADS=4
srun $MESH_MPI

