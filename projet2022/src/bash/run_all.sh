#!/bin/bash
for x in `ls ./test/$1`; do
    if [[ $x == *".c" ]]; then
            "make" "-s" "run" "FILE=$x";
    fi
done