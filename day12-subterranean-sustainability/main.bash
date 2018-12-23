#!/bin/bash

# read input
input=$(</dev/stdin)

input_initial_state=$(echo "$input" | sed -n '1 s/^initial state: \(.*\)$/\1/p')
input_rules=$(echo "$input" | sed -n '3,$ s/^\([#.]*\) => #$/\1/gp')

# use map because want negative indexes
declare -A state_map
input_initial_state_length="${#input_initial_state}"
range_start=-2
range_end=$(( input_initial_state_length - 1 + 2 ))
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

for (( generation = 1; generation <= 20; ++generation )); do
    printf "$generation: "
    range_start_new=$range_start
    range_end_new=$range_end
    for (( i = range_start; i <= range_end; ++i )); do

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
            if [[ $i -lt $(( range_start_new + 2)) ]]; then
                range_start_new=$(( i - 2 ))
            elif [[ $i -gt $(( range_end_new - 2 )) ]]; then
                range_end_new=$(( i + 2 ))
            fi

        else
            state_map[$i]="."
        fi

        printf "${state_map[$i]}"

    done
    echo;
    range_start=$range_start_new
    range_end=$range_end_new
done;

# sum up numbers of pots containing plants
plant_number_sum=0
for plant_number in "${!state_map[@]}"; do
    if [[ ${state_map[$plant_number]} == '#' ]]; then
        (( plant_number_sum+=plant_number ))
    fi
done

echo "$plant_number_sum"


: << 'END_COMMENT'


iterate through range while keeping 2 pots to the left and right (sliding "buffer"). For each:
    if buffer is in map
        set to 

END_COMMENT






echo "$plant_count"
