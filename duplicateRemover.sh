#!/bin/bash



cat -n ./$1 | sort -uk2 | sort -nk1  | \
    cut -f2- > ./input/input927.csv
