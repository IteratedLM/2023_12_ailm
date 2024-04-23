#!/bin/bash

# Define the values to loop over
#values=(1 2 3 4 5 6 7 8 9 10 11 13 15 17 19 21 23 25)
#for trial0 in "${values[@]}"; do

for trial0 in {1..25} 
do
    for n in {8..16}
    do
	     sbatch runFig.sh $n $trial0
	     sleep 60
    done
    sleep 600
done

echo "All iterations complete."
