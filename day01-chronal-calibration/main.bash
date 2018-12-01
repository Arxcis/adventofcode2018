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

SEEN=()
CURRENT=0
INPUT=("$@")
INPUT_LENGTH=${#INPUT[@]}
INPUT_INDEX=0
DONE=false

while true; do


    # if already seen, break. we're done
    for E in "${SEEN[@]}"; do
        if [[ $CURRENT = $E ]]; then
            echo "yay!"
            echo $E
            DONE=true
            break
        fi
    done

    if [[ $DONE = true ]]; then
        break
    fi

    # if got here, not already seen. add to seen
    SEEN+=($CURRENT)



    # calc next freq
    CHANGE="${INPUT[$INPUT_INDEX]}"
    CURRENT=$((CURRENT + CHANGE))

    #echo "CURR: $CURRENT, I: $INPUT_INDEX, CHANGE (made): $CHANGE"

    # make sure the loop wraps
    ((INPUT_INDEX++))
    if [[ $INPUT_INDEX -ge $INPUT_LENGTH ]]; then
        INPUT_INDEX=0
        #echo "looping... size of seen: ${#SEEN[@]}"
    fi

done

echo "part2 $CURRENT"

