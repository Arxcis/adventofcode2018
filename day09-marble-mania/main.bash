#!/bin/bash









# https://unix.stackexchange.com/questions/328882/how-to-add-remove-an-element-to-from-the-array-in-bash

input=$(</dev/stdin)
parsed_input=($(echo "$input" | sed 's/^\([[:digit:]]*\) players; last marble is worth \([[:digit:]]*\) points$/\1 \2/'))


num_players=${parsed_input[0]}
last_marble=${parsed_input[1]}

echo "${parsed_input[@]}"


array=(0)
current_index=0
current_player=1
marble=1

function inc_current_index() {
    ((current_index++))
    if [[ $current_index -ge "${#array[@]}" ]]; then
        current_index=0
    fi
}

function inc_current_player() {
    ((current_player++))
    if [[ $current_player -gt "$num_players" ]]; then
        current_player=1
    fi
}


declare -A player_map

while [[ $marble -le $last_marble ]]; do



    if (( !(marble % 23) )); then
    
        echo "yay index is $current_index tho (-7: $(( current_index - 7 )))"
        current_index=$(( current_index - 7 ))

        # (never happens??)
        if [[ $current_index -lt 0 ]]; then
            echo "array: ${array[@]}"
            length=${#array[@]}
            echo "OBS was $current_index (length is $length) (math: $(( current_index + length ))"
            current_index=$(( current_index + length ))
            echo "OBS $current_index"
        fi

        echo "$marble yay! (removed $current_index which was ${array[$current_index]})"

        # give points to current_index player
        previous_score="${player_map[$current_player]}"
        removed_marble="${array[$current_index]}"
        player_map[$current_player]=$(( previous_score + marble + removed_marble))
        echo "player $current_player now has ${player_map[$current_player]} score [$previous_score + $marble + $removed_marble]"

        # remove element at current_index by shifting array to the left after current_index
        #length=${#array[@]}
        #for (( i = current_index; i < length; ++i )); do
        #    array[$i]="${array[$(( i + 1 ))]}"
        #done
        #length_minus_one=$(( length - 1 ))
        #unset array[$length_minus_one]

        #array=( "${array[@]:0:$(( current_index - 1 ))}" "${array[@]:$(( current_index ))}")

        unset array[$current_index]
        new_array=()
        for value in ${array[@]}; do
            new_array+=($value)
        done
        array=()
        for value in ${new_array[@]}; do
            array+=($value)
        done

        #echo "val: ${array[$current_index]}"


    else

        inc_current_index
        inc_current_index
        #echo "-->$current_index"
        array=( "${array[@]:0:$current_index}" "$marble" "${array[@]:$current_index}" )
        
        # make space
        #length="${#array[@]}"
        #for (( i = current_index + 1; i <= length; ++i )); do
        #    array[$i]=${array[$(( i - 1 ))]}
        #done
        #array[$current_index]=$marble

    fi

    #echo -e "[$current_player]->$current_index ($marble) \t${array[@]}"

    inc_current_player
    ((marble++))


done

# find winner
max_score=-1
for score in "${player_map[@]}"; do
    if [[ $score -gt $max_score ]]; then
        max_score=$score
    fi
done

echo "$max_score"
