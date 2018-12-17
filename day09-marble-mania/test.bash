#!/bin/bash



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

function print_current_verbose() {
    echo -e "[${map_v[$current_id]}]\t${map_p[$current_id]} <- $current_id -> ${map_n[$current_id]}"
}

function print_current() {
    echo "${map_v[$current_id]}"
}

function print_list_verbose() {
    local backup_current=$current_id

    echo "LIST:"
    print_current_verbose
    clockwise
    while [[ $current_id -ne $backup_current ]]; do

        print_current_verbose
        clockwise

    done

    current_id=$backup_current
}

function print_list() {
    local backup_current=$current_id
    current_id=0

    printf "LIST: "
    printf "$(print_current) "
    clockwise
    while [[ $current_id -ne "0" ]]; do

        printf "$(print_current) "

        clockwise

    done
    echo;

    current_id=$backup_current
}

declare -A map_n
declare -A map_p


input=$(</dev/stdin)
parsed_input=($(echo "$input" | sed 's/^\([[:digit:]]*\) players; last marble is worth \([[:digit:]]*\) points$/\1 \2/'))


#num_players=10
last_marble=1618

map_v[0]=0
map_n[0]=0
map_p[0]=0

next_id=1
current_id=0

marble=1


#current_player=1


#declare -A player_map

while [[ $marble -le $last_marble ]]; do



    if (( !(marble % 23) )); then

        counter_clockwise
        counter_clockwise
        counter_clockwise
        counter_clockwise
        counter_clockwise
        counter_clockwise
        counter_clockwise


        #previous_score="${player_map[$current_player]}"
        deleted_marble=$(print_current)


        #player_map[$current_player]=$(( previous_score + marble + deleted_marble ))

        echo -e "[$(print_current)]\tscore is marble:\t$marble + deleted:\t$deleted_marble = $(( marble + deleted_marble ))"

        delete_current_and_set_to_next

    else


        clockwise
        inset_after_current $marble
        clockwise


    fi

    #echo "marble: $marble, player: $current_player-----------------------------"
    #print_list_verbose 
    #printf "[player: $current_player] "
    #print_list

    ((marble++))

    ((current_player++))
    if [[ $current_player -gt "$num_players" ]]; then
        current_player=1
    fi

done


# find winner
max_score=-1
for score in "${player_map[@]}"; do
    #echo "$score"
    if [[ $score -gt $max_score ]]; then
        max_score=$score
    fi
done

echo "$max_score"
