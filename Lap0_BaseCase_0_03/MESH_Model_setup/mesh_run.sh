#!/bin/bash

MESH_MPI=/home/zelalem/MESH_Code/r1860_ME_ZT_DP_FY/mpi_sa_mesh
export OMP_NUM_THREADS=8
srun $MESH_MPI

