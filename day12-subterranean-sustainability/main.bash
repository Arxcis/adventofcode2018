#!/bin/bash

# read input
input=$(</dev/stdin)

input_initial_state=$(echo "$input" | sed -n '1 s/^initial state: \(.*\)$/\1/p')
input_rules=$(echo "$input" | sed -n '3,$ s/^\([#.]*\) => #$/\1/gp')

# use map because want negative indexes
declare -A state_map
input_initial_state_length="${#input_initial_state}"
range_start=0
range_end=$(( input_initial_state_length - 1 ))
for (( i = 0; i < input_initial_state_length; ++i )); do
    pot_state="${input_initial_state:$i:1}"
    state_map["$i"]="$pot_state"
done


# build rule map
# using map as set
declare -A rule_map
while read -r rule; do
    rule_map[$rule]=1
done < <(echo "$input_rules")



buffer="....."
buffer_length=5

echo "0: $input_initial_state"

fifty_billion=50000000000
for (( generation = 1; generation <= fifty_billion; ++generation )); do
    printf "$generation: "
    recurring=true
    for (( i = range_start - 2; i <= range_end + 2; ++i )); do

        index_to_buffer=$(( i + 2 ))
        value_to_buffer="${state_map[$index_to_buffer]}"
        if [[ -z "$value_to_buffer" ]]; then
            value_to_buffer="."
        fi
        
        # advance buffer
        buffer=${buffer:1:$buffer_length}
        buffer+=$value_to_buffer

        if [[ ${rule_map[$buffer]+_} ]]; then
            state_map[$i]="#"
        else
            state_map[$i]="."
        fi

        printf "${state_map[$i]}"
        if [[ ${state_map[$i]} != ${buffer:1:1} ]]; then
            recurring=false
        fi

    done
    echo;


    range_start=$(( range_start - 2 ))
    while [[ ${state_map[$range_start]} != "#" ]]; do
        ((range_start++))
    done

    range_end=$(( range_end + 2 ))
    while [[ ${state_map[$range_end]} != "#" ]]; do
        ((range_end--))
    done

    if $recurring; then
        echo "RECURRING"
        break
    fi

done;

echo "$generation"

# sum up numbers of pots containing plants
plant_number_sum=0
for plant_number in "${!state_map[@]}"; do
    if [[ ${state_map[$plant_number]} == '#' ]]; then
        plant_number=$(( plant_number + fifty_billion - generation ))
        echo $plant_number
        (( plant_number_sum+=plant_number ))
    fi
done

echo "$plant_number_sum"


: << 'END_COMMENT'


iterate through range while keeping 2 pots to the left and right (sliding "buffer"). For each:
    if buffer is in map
        set to 

999999999394
999999999394
999999999394

END_COMMENT






echo "$plant_count"
