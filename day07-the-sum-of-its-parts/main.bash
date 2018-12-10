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





# PART 2

worker_num=5
worker_task=(0 0 0 0 0)
worker_time=(0 0 0 0 0)




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
time=-1
part_1_output=""
while [[ ${#nochildren[@]} -gt 0 ]]; do


    echo "worker_task before: ${worker_task[@]}"
    echo "worker_time before: ${worker_time[@]}"

    # decrease time by one for each worker
    for (( i=0; i<worker_num; i++ )); do
        echo "looking at worker ${worker_task[$i]}"
        if [[ "${worker_task[$i]}" != "0" ]]; then
            if [[ ${worker_time[$i]} -gt 1 ]]; then
                worker_time[$i]=$(( ${worker_time[$i]} - 1 ))
            else

                task=${worker_task[$i]}
                worker_task[$i]=0
                worker_time[$i]=0

                # remove refs from map
                for node in "${!map[@]}"; do
                    map[$node]=${map[$node]//$task}
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
                nochildren=(${nochildren[@]/$task})

                #echo "-->removed $node from nochildren"

                # sort nochildren
                length=${#nochildren[@]}
                for (( j=0; j<length; j++ )); do
                    min_index=$j
                    min_val=${nochildren[$j]}
                    for (( k=j+1; k<length; k++ )); do
                        if [[ ${nochildren[$k]} < $min_val ]]; then
                            min_index=$k
                            min_val=${nochildren[$k]}
                        fi
                    done
                    tmp=${nochildren[$j]}
                    nochildren[$j]=${nochildren[$min_index]}
                    nochildren[$min_index]=$tmp
                done

            fi
        fi
    done

    echo "worker_task after : ${worker_task[@]}"
    echo "worker_time after : ${worker_time[@]}"

    for node in ${nochildren[@]}; do
        echo "${worker_task[@]}"
        echo $node
        if [[ ! "${worker_task[@]}" =~ "$node" ]]; then
            for (( i=0; i<worker_num; i++ )); do
                if [[ ${worker_task[$i]} == 0 ]]; then
                    value_node=$(printf '%d' "'$node")
                    value_A=$(printf '%d' "'A")
                    value=$(( value_node - value_A + 1 + 60 ))
                    echo "$node inserted with $value"
                    worker_task[$i]=$node
                    worker_time[$i]=$value
                    part_1_output+=$node
                    break
                fi
            done
        fi
    done


    #echo "curr: $current"
    #printf $current


    #echo "-->nochildren: ${nochildren[@]}"

    ((time++))
    echo "time: $time"
done

echo $part_1_output
echo $time


: << 'END_COMMENT'

map node -> nodefader1, nodefader2, ... , nodefaderN

fra noder i map med null fedre, finn neste i alfabetisk rekkefølge
    skriv ut
    fjern alle referanser til denne som fader
    fjern entry
END_COMMENT



echo


# XBEFLNGIRQUHPSJKVTYOCZDWMA










