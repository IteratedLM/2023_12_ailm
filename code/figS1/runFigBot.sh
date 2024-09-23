#!/bin/bash 

#SBATCH --mem=10000M
#SBATCH --partition=compute
#SBATCH --job-name=ilm_vb
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --account COSC016682

module purge
module add languages/julia

cd "${SLURM_SUBMIT_DIR}"

hostname
echo $1 

julia figBottle.jl $1

