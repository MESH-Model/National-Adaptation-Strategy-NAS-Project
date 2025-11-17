#!/bin/bash
#SBATCH --account=def-kshook #rpp-kshook
#SBATCH --nodes=1
#SBATCH --gres=gpu:v100:8
#SBATCH --exclusive
#SBATCH --cpus-per-task=28
#SBATCH --mem=150G
#SBATCH --time=00:10:00
#SBATCH --job-name=CaSRv2p1_MESH_Run
#SBATCH --error=errors_CaSRv2p1
#
MESH_MPI=/home/zelalem/MESH_Code/r1860_ME_ZT3/mpi_sa_mesh
srun $MESH_MPI

