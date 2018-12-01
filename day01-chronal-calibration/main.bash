#!/bin/bash

# PART 1

RESULT=0
INPUT="$@"

# add every freq in input to RESULT
for var in $INPUT; do
    RESULT=$(($RESULT + $var))
done

echo "part1 $RESULT"
