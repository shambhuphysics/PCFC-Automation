#!/bin/bash

#SBATCH --job-name=eamfit
#SBATCH --nodes=1   
#SBATCH --ntasks-per-node=40
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --error=eamfit.%j.err
#SBATCH --output=eamfit.%j.out
#SBATCH --mail-user=ucfbsbh@ucl.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

# Purging and reloading all modules to be sure of the job's environment
module purge
module load ucl-stack/2025-05
module load compilers/intel-oneapi/2024.2.1/gcc-12.3.0
module load mpi/intel-oneapi-mpi/2021.14.0/intel-oneapi-2024.2.1
module load intel-oneapi-mkl/2023.2.0-intel-oneapi-mpi/intel-oneapi-2024.2.1

# Set environment variables for Intel MPI
export OMP_NUM_THREADS=1
export I_MPI_PIN_DOMAIN=omp
export I_MPI_PIN=1

./pipeline.sh
