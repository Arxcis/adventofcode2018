#!/bin/bash

# read input and remove comma and newline
input=$(</dev/stdin)
parsed_input=$(echo "$input" | sed 's/^Step \([[:alpha:]]\) must be finished before step \([[:alpha:]]\) can begin.$/\1 \2/g')

declare -A map

while read -r line; do
    line=($line)
    map[${line[1]}]="${map[${line[1]}]}${line[0]}"
done <<< $(echo "$parsed_input")

# add entries with no children
nochildren=()
for var in ${!map[@]}; do
    refs="${map[$var]}"
    #echo "asdf: $refs"
    for (( i=0; i<${#refs}; i++ )); do
        father=${refs:$i:1}
        #echo "asdfasdf: $father"
        if [[ -z ${map[$father]+_} ]] && [[ ! "${nochildren[@]}" =~ "${father}" ]]; then
            nochildren+=($father)
        fi
    done
done


# sort nochildren
length=${#nochildren[@]}
for (( i=0; i<length; i++ )); do
    min_index=$i
    min_val=${nochildren[$i]}
    for (( j=i+1; j<length; j++ )); do
        if [[ ${nochildren[$j]} < $min_val ]]; then
            min_index=$j
            min_val=${nochildren[$j]}
        fi
    done
    tmp=${nochildren[$i]}
    nochildren[$i]=${nochildren[$min_index]}
    nochildren[$min_index]=$tmp
done

# until no nodes left to look at
while [[ ${#nochildren[@]} -gt 0 ]]; do

    # remove front
    current=${nochildren[0]}

    #echo "curr: $current"
    printf $current

    # remove refs from map
    for node in "${!map[@]}"; do
        map[$node]=${map[$node]//$current}
        #echo "-->$node : ${map[$node]}"
        
        # if now doesn't have any dads, add to nochildren
        refs="${map[$node]}"
        if [[ "${#refs}" == "0" ]]; then
            unset map[$node]
            nochildren+=($node)
            #echo "-->removed $node"
            #echo "-->nochildren: ${nochildren[@]}"
        fi

    done

    # remove from nochildren
    nochildren=(${nochildren[@]/$current})

    #echo "-->removed $current from nochildren"

    # sort nochildren
    length=${#nochildren[@]}
    for (( i=0; i<length; i++ )); do
        min_index=$i
        min_val=${nochildren[$i]}
        for (( j=i+1; j<length; j++ )); do
            if [[ ${nochildren[$j]} < $min_val ]]; then
                min_index=$j
                min_val=${nochildren[$j]}
            fi
        done
        tmp=${nochildren[$i]}
        nochildren[$i]=${nochildren[$min_index]}
        nochildren[$min_index]=$tmp
    done

    #echo "-->nochildren: ${nochildren[@]}"
done


: << 'END_COMMENT'

map node -> nodefader1, nodefader2, ... , nodefaderN

fra noder i map med null fedre, finn neste i alfabetisk rekkefølge
    skriv ut
    fjern alle referanser til denne som fader
    fjern entry
END_COMMENT



echo


# XBEFLNGIRQUHPSJKVTYOCZDWMA
