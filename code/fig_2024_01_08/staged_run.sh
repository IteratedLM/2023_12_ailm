#!/bin/bash

for batchC in {1..20} 
do
    sbatch runFig.sh $batchC
    sleep 60
done

echo "All iterations complete."
