#!/bin/bash

# Define the values to loop over
values=(1 6 11 16 21)

for trial0 in "${values[@]}"; do
    for n in {8..15}
    do
	     echo $n $trial0
	     sleep 1
    done
    sleep 1
done

echo "All iterations complete."
