#!/bin/bash

source_dir="./"

target_dir="./slurm_out/"

mkdir -p "$target_dir"

find "$source_dir" -name "*.out" -mtime +2 -exec mv {} "$target_dir" \;

for i in {50..425..25}; do
    echo ""
    echo $i
    sbatch runFigRef.sh $i
    sleep 60
done

echo "All iterations complete."

