#!/bin/bash

source_dir="./"

target_dir="./slurm_out/"

mkdir -p "$target_dir"

find "$source_dir" -name "*.out" -mtime +2 -exec mv {} "$target_dir" \;

for i in {10..200..10}; do
    echo ""
    echo $i
    sbatch runFigBot.sh $i
    sleep 5
done

echo "All iterations complete."

