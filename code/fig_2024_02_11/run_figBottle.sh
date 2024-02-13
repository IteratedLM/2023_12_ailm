#!/bin/bash

for i in {10..150..10}; do
    echo ""
    echo $i
    julia figBottle.jl $i
done
