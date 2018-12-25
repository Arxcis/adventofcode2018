#!/bin/bash

###############################################################################
### UTIL
###############################################################################

# global variable used for "returning" from functions
ret=-1

# trims the range of pots looked at while calculating the next generation
# Assumption: the range can never increase by more than 2 on each side, because 
#             rules only look at two pots on each side. The extreme is a rule 
#             like "....# => #" which will increase the range by 2
function trim_range() {

    range_start=$(( range_start - 2 ))
    while [[ ${state_map[$range_start]} != "#" ]]; do
        ((range_start++))
    done

    range_end=$(( range_end + 2 ))
    while [[ ${state_map[$range_end]} != "#" ]]; do
        ((range_end--))
    done

}

# returns the sum of plant numbers for all plants in state_map
# (uses $ret variable)
function sum_plant_numbers() {

    plant_number_sum=0
    for plant_number in "${!state_map[@]}"; do
        if [[ ${state_map[$plant_number]} == '#' ]]; then
            (( plant_number_sum+=plant_number ))
        fi
    done

    ret=$plant_number_sum

}


###############################################################################
### PARSE INPUT
###############################################################################

# read input
input=$(</dev/stdin)

input_initial_state=$(echo "$input" | sed -n '1 s/^initial state: \(.*\)$/\1/p')
input_initial_state_length="${#input_initial_state}"

# use map because want negative indexes.
# overhead of map is not a big problem since (at least for my input) the range 
# of pots to lookup for each generation maxes out at under 200
declare -A state_map

# fill state_map with pot states from input initial state
for (( i = 0; i < input_initial_state_length; ++i )); do
    pot_state="${input_initial_state:$i:1}"
    state_map["$i"]="$pot_state"
done

# set initial range and trim using util function
#
# range_start and range_end stores the plant_numbers of the left-most and right-most 
# plant. This is done to store what range of pots we should look at while calculating 
# the next generation.
range_start=0
range_end=$(( input_initial_state_length - 1 ))
trim_range

input_rules=$(echo "$input" | sed -n '3,$ s/^\([#.]*\) => #$/\1/gp')

# build rule map
# using map as set
# NOTE that only stores rules that produce a "#"
declare -A rule_map
while read -r rule; do
    rule_map[$rule]=1
done < <(echo "$input_rules")

###############################################################################
### SOLVE PART 1 AND 2
###
### Advances the pot states by applying the input ruleset. Solves part 1 and 2:
###   * Part 1: Outputs sum of plant numbers as soon as reaches generation 20
###   * Part 2: Looks for a recurring pattern (a pot state that produces itself
###             shifted a few pots to the left or right). Once such a pattern 
###             is found we can jump straight to the solution by shifting the 
###             state_map to the left/right to where it should end up after 
###             50000000000 generations. The plant_number sum is calculated, 
###             and the left/right shifting is done by adding the number of 
###             plants timed by how much to shift each plant number to the 
###             result.
###
### This solve assumes that:
###   1. A recurring pattern exists for part 2
###   2. No rule like "..... => #" exist
### 
### NOTE: not tested with input that shifts to the left
### TODO: support shift of two (which I think is possible?)
###############################################################################


# buffer stores the pot states around the current pot at all times
# this is done to edit the state_map in-place
buffer="....."
buffer_length=5

# NOTE: This loop will likely finish before generation fifty_billion is ever 
#       reached, but it is written in this way to theoretically support an 
#       input without a recurring pattern.

fifty_billion=50000000000
for (( generation = 1; generation <= fifty_billion; ++generation )); do
    
    # flag to store if a recurring pattern is found. 
    recurring_left=true
    recurring_right=true
    
    # apply ruleset to every pot in range
    # -2 and +2 because rules like "....#" can effect pots outside our range
    for (( i = range_start - 2; i <= range_end + 2; ++i )); do

        # find next pot state to buffer
        index_to_buffer=$(( i + 2 ))
        value_to_buffer="${state_map[$index_to_buffer]}"

        # if state_map did not have an entry, treat it as a "."
        if [[ -z "$value_to_buffer" ]]; then
            value_to_buffer="."
        fi
        
        # advance buffer
        buffer=${buffer:1:$buffer_length}
        buffer+=$value_to_buffer

        # update next generation $i by looking up if there is a "#" rule for 
        # buffer in the rule_map
        if [[ ${rule_map[$buffer]+_} ]]; then
            state_map[$i]="#"
        else
            state_map[$i]="."
        fi

        # set recurring flags to false if can prove that they cannot be true

        if [[ ${state_map[$i]} != ${buffer:1:1} ]]; then
            recurring_right=false
        fi

        if [[ ${state_map[$i]} != ${buffer:-1:1} ]]; then
            recurring_left=false
        fi

    done

    trim_range

    # if reached generation 20 can output solution to part 1
    if [[ $generation -eq 20 ]]; then
        sum_plant_numbers
        echo "$ret"
    fi

    
    # if a recurring pattern is found skip to the solution of part 2 and break
    if $recurring_left || $recurring_right; then

        # count number of plants
        number_of_plants=0
        for pot_state in "${state_map[@]}"; do
            if [[ $pot_state == "#" ]]; then
                ((number_of_plants++))
            fi
        done

        sum_plant_numbers

        sum_of_shifts="$(( number_of_plants * (50000000000 - generation) ))"

        # if should shift to the left make sum negative
        if $recurring_left; then
            sum_of_shifts=$(( 0 - sum_of_shifts ))
        fi

        echo "$(( ret + sum_of_shifts ))"

        break

    fi

done;
