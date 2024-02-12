#!/bin/bash

for trial0 in {1..25} 
do
    sbatch runFig.sh $trial0
    sleep 60
done

echo "All iterations complete."
