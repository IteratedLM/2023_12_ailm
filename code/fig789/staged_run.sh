#!/bin/bash

for trial0 in {1..5} 
do
    sbatch runFig.sh $trial0
    sleep 10
done

echo "All iterations complete."
