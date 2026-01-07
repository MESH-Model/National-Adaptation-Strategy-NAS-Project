#!/bin/bash
#SBATCH --job-name=mesh_run
#SBATCH --account=def-kshook
#SBATCH --cpus-per-task=16
#SBATCH --time=05:58:00
#SBATCH --mem=8G

MESH_MPI=/scratch/zelalem/CanTrans-models/MESH-Dev-SA_MESH_1.5-SA_MESH_1.5.5/mpi_sa_mesh
#MESH_MPI=/scratch/zelalem/CanTrans-models/r1860_ME_ZT/mpi_sa_mesh

export OMP_NUM_THREADS=8
srun $MESH_MPI

