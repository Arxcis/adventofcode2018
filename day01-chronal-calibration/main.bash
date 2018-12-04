#!/bin/bash

# read input from stdin
INPUT=()
while read LINE; do
    INPUT+=($LINE)
done

# PART 1

RESULT=0

# add every freq in input to RESULT
for VAR in ${INPUT[@]}; do
    RESULT=$(($RESULT + $VAR))
done

echo $RESULT

# PART 2
# Takes a few seconds :)
# The map functionality requires Bash 4.3 according to https://stackoverflow.com/a/30757358

declare -A SEEN             # Map of seen frequencies (used as set)
CURRENT=0                   # current freq
INPUT_LENGTH=${#INPUT[@]}   # the length of the input array (stored for readability)
INPUT_INDEX=0               # Our current index in the input array

while true; do

    # if already seen, break. we're done
    if [[ -v SEEN[$CURRENT] ]]; then
        break
    fi

    # add to seen
    # (value not used)
    SEEN[$CURRENT]=1

    # calc next freq
    CHANGE="${INPUT[$INPUT_INDEX]}"
    CURRENT=$((CURRENT + CHANGE))

    # make sure the loop wraps
    ((INPUT_INDEX++))
    if [[ $INPUT_INDEX -ge $INPUT_LENGTH ]]; then
        INPUT_INDEX=0
    fi
done

echo $CURRENT

