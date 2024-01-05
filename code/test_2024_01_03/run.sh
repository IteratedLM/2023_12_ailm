#!/bin/bash 

#SBATCH --mem=10000M
#SBATCH --partition=gpu
#SBATCH --job-name=ilm
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --account COSC016682

module purge
module add languages/julia/1.8.2


cd "${SLURM_SUBMIT_DIR}"
echo 'hello world'
echo "$(pwd)$"
julia fig.jl
hostname
