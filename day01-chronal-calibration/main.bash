#!/bin/bash

# PART 1

RESULT=0
INPUT="$@"

# add every freq in input to RESULT
for var in $INPUT; do
    RESULT=$(($RESULT + $var))
done

echo "part1 $RESULT"

# PART 2
# NOTE: The map functionality requires Bash 4.3 according to https://stackoverflow.com/a/30757358

declare -A SEEN
CURRENT=0
INPUT=("$@")
INPUT_LENGTH=${#INPUT[@]}
INPUT_INDEX=0

while true; do

    # if already seen, break. we're done
    if [[ -v SEEN[$CURRENT] ]]; then
        break
    fi

    # if got here, not already seen. add to seen
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

echo "part2 $CURRENT"

