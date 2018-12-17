#!/bin/bash

###############################################################################
### DOUBLY LINKED LIST IMPLEMENTATION
###
### Task requires lots of insertions and deletions, but no random access, so 
### a doubly linked list is faster than an array. Bash does not have a built-in 
### doubly linked list, and does not support pointers, so easiest way to 
### achieve the behavior is with maps
###############################################################################

function reset_list() {  

    unset map_n
    unset map_p
    declare -Ag map_n
    declare -Ag map_p

    current_id=0
    next_id=1

    # initially contains only the 0 value (as specified in the task)
    map_v[0]=0
    map_n[0]=0
    map_p[0]=0
}

function inset_after_current() {

    after=$current_id
    value=$1

    map_v[$next_id]=$value

    map_p[${map_n[$after]}]=$next_id

    map_n[$next_id]=${map_n[$after]}
    map_p[$next_id]=$after

    map_n[$after]=$next_id

    ((next_id++))
}

function delete_current_and_set_to_next() {

    current_p=${map_p[$current_id]}
    current_n=${map_n[$current_id]}
    
    map_n[$current_p]=$current_n
    map_p[$current_n]=$current_p

    unset map[$current_id]

    current_id=$current_n
}

function clockwise() {
    current_id="${map_n[$current_id]}"
}

function counter_clockwise() {
    current_id="${map_p[$current_id]}"
}

function print_current() {
    echo "${map_v[$current_id]}"
}

###############################################################################
### MARBLE GAME
###
### Generic implementation used for both part 1 and 2. Uses the doubly 
### linked list
###############################################################################

function play_game() {

    num_players=$1
    last_marble=$2
    
    # initialize loop varibles
    local marble=1
    local current_player=1

    # stores score for each player
    declare -A player_map

    while [[ $marble -le $last_marble ]]; do

        if (( !(marble % 23) )); then

            counter_clockwise
            counter_clockwise
            counter_clockwise
            counter_clockwise
            counter_clockwise
            counter_clockwise
            counter_clockwise

            local previous_score="${player_map[$current_player]}"
            local deleted_marble=$(print_current)

            player_map[$current_player]=$(( previous_score + marble + deleted_marble ))

            delete_current_and_set_to_next

        else

            clockwise
            inset_after_current $marble
            clockwise

        fi

        ((marble++))

        # move to next player. goes to player 1 when wrapping
        ((current_player++))
        if [[ $current_player -gt "$num_players" ]]; then
            current_player=1
        fi

    done

    # find winner
    for score in "${player_map[@]}"; do
        if [[ $score -gt $max_score ]]; then
            max_score=$score
        fi
    done

    echo "$max_score"
}

###############################################################################
### PARSE INPUT
###############################################################################

input=$(</dev/stdin)
parsed_input=($(echo "$input" | sed 's/^\([[:digit:]]*\) players; last marble is worth \([[:digit:]]*\) points$/\1 \2/'))

num_players=${parsed_input[0]}
last_marble=${parsed_input[1]}

###############################################################################
### PART 1
###############################################################################

reset_list
echo "$(play_game $num_players $last_marble)"

###############################################################################
### PART 2
###
### Just part 1 with last_marble * 100
###############################################################################

reset_list
echo "$(play_game $num_players $((last_marble * 100 )))"
