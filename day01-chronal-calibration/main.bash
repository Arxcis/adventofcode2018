#!/bin/bash

# read input from stdin
input=()
while read -r line; do
    input+=($line)
done

# PART 1

result=0

# add every freq in input to RESULT
for freq in "${input[@]}"; do
    result=$((result + freq))
done

echo $result

# PART 2
# Takes a few seconds :)
# The map functionality requires Bash 4.3 according to https://stackoverflow.com/a/30757358

declare -A seen             # Map of seen frequencies (used as set)
current=0                   # current freq
input_length=${#input[@]}   # the length of the input array (stored for readability)
input_index=0               # Our current index in the input array

while true; do

    # if already seen, break. we're done
    if [[ ${seen[$current]+_} ]]; then
        break
    fi

    # add to seen
    # (value not used)
    seen[$current]=1

    # calc next freq
    change="${input[$input_index]}"
    current=$((current + change))

    # make sure the loop wraps
    ((input_index++))
    if [[ $input_index -ge $input_length ]]; then
        input_index=0
    fi
done

echo $current

