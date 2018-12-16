#!/bin/bash

# https://unix.stackexchange.com/questions/328882/how-to-add-remove-an-element-to-from-the-array-in-bash

array=(0)
current=0
marble=0

function inc_current() {
    ((current++))
    if [[ $current -ge "${#array[@]}" ]]; then
        current=0
    fi
}

while true; do

    ((marble++))
    echo -e "->$current ($marble) \t${array[@]}"

    if (( !(marble % 23) )); then
    
        current=$(( current - 8 ))
        echo "$marble yay! (removed $current which was ${array[$current]})"
        

        # remove element at current by shifting array to the left after current
        length=${#array[@]}
        for (( i = current; i < length; ++i )); do
            array[$i]="${array[$(( i + 1 ))]}"
        done
        unset "array[$length]"

        inc_current

    else

        inc_current
        array=( "${array[@]:0:$current}" "$marble" "${array[@]:$current}" )
        inc_current

    fi

    sleep 0.1

done
