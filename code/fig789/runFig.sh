#!/bin/bash 

#SBATCH --mem=10000M
#SBATCH --partition=short
#SBATCH --job-name=ilm_09
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --account COSC016682

module purge
module add lang/julia/1.8.5

cd "${SLURM_SUBMIT_DIR}"

hostname
echo $1 

julia fig.jl $1

