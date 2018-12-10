#!/bin/bash

###############################################################################
### SETUP
### 
### This section contains setup common to part 1 and 2
###############################################################################

# read input and remove comma and newline
input=$(</dev/stdin)
parsed_input=$(echo "$input" | sed 's/^Step \([[:alpha:]]\) must be finished before step \([[:alpha:]]\) can begin.$/\1 \2/g')

# this map is structured like this:
#   depends_on_map[<node>]="<dependency1><dependency2>"
# So the node E from the example input would look like this:
#   depends_on_map[E]="BDF" 
declare -A depends_on_map

# no_dependencies is an array containing the nodes that have no 
# dependencies, and so are ready to be printed / processed by a worker
#
# the array is kept sorted in ascending order, see function below
no_dependencies=()

setup_depends_on_map() {

    # build depends_on_map from input
    while read -r line; do
        line=($line)
        depends_on_map[${line[1]}]="${depends_on_map[${line[1]}]}${line[0]}"
    done <<< $(echo "$parsed_input")

    # initialize no_dependencies array with nodes that have no dependencies in input
    for var in ${!depends_on_map[@]}; do
        dependencies="${depends_on_map[$var]}"
        for (( i=0; i<${#dependencies}; i++ )); do
            dependency=${dependencies:$i:1}
            if [[ -z ${depends_on_map[$dependency]+_} ]] && 
               [[ ! "${no_dependencies[@]}" =~ "${dependency}" ]]; then

                no_dependencies+=($dependency)
            fi
        done
    done
}

# sorts no_dependencies in ascending order using selection sort
# made into function as sorting is needed many places
sort_no_dependencies() {

    # declare all variables used in this function as local to 
    # prevent affecting other code
    local length=${#no_dependencies[@]} i j min_index min_val

    for (( i=0; i<length; i++ )); do

        min_index=$i
        min_val=${no_dependencies[$i]}
        for (( j=i+1; j<length; j++ )); do
            if [[ ${no_dependencies[$j]} < $min_val ]]; then
                min_index=$j
                min_val=${no_dependencies[$j]}
            fi
        done

        # swap 
        local tmp=${no_dependencies[$i]}
        no_dependencies[$i]=${no_dependencies[$min_index]}
        no_dependencies[$min_index]=$tmp

    done
}

###############################################################################
### PART 1
###############################################################################

# call setup functions
setup_depends_on_map
sort_no_dependencies

part_1_solution=""

# until no nodes left to look at:
#   remove front of no_dependencies and add it to the output
#   remove all references to it in depends_on_map
#   add nodes that now have no dependencies to no_dependencies
#   remove it from no_dependencies
while [[ ${#no_dependencies[@]} -gt 0 ]]; do

    # remove front
    current=${no_dependencies[0]}

    # add current to solution
    part_1_solution+=$current

    # remove dependancy entries from depends_on_map
    for node in "${!depends_on_map[@]}"; do

        depends_on_map[$node]=${depends_on_map[$node]//$current}
        
        # if now doesn't have any dependencies, add to no_dependencies
        deps="${depends_on_map[$node]}"
        if [[ "${#deps}" == "0" ]]; then
            unset depends_on_map[$node]
            no_dependencies+=($node)
        fi

    done

    # remove from no_dependencies
    no_dependencies=(${no_dependencies[@]/$current})

    # sort using our function
    sort_no_dependencies

done

echo "$part_1_solution"


###############################################################################
# PART 2
###############################################################################


# worker i's state is stored in two arrays:
#   worker_task[i] stores what instruction the worker is currently working on
#   worker_time[i] stores the time until the task is finished
# (NOTE that this part needs to be manually changed for the example input to work)
worker_num=5
worker_task=(0 0 0 0 0)
worker_time=(0 0 0 0 0)


# call setup functions
setup_depends_on_map
sort_no_dependencies

# -1 because first round of loop is used for setup
time=-1

while [[ ${#no_dependencies[@]} -gt 0 ]]; do

    ((time++))

    # decrease time by one for each worker
    for (( i=0; i<worker_num; i++ )); do

        if [[ "${worker_task[$i]}" != "0" ]]; then
            
            if [[ ${worker_time[$i]} -gt 1 ]]; then

                worker_time[$i]=$(( ${worker_time[$i]} - 1 ))
                
            else

                task=${worker_task[$i]}
                worker_task[$i]=0
                worker_time[$i]=0

                # remove dependency entries from depends_on_map
                for node in "${!depends_on_map[@]}"; do

                    depends_on_map[$node]=${depends_on_map[$node]//$task}
                    
                    # if now doesn't have any dads, add to no_dependencies
                    refs="${depends_on_map[$node]}"
                    if [[ "${#refs}" == "0" ]]; then
                        unset depends_on_map[$node]
                        no_dependencies+=($node)
                    fi

                done

                # remove from no_dependencies
                no_dependencies=(${no_dependencies[@]/$task})

                # sort no_dependencies
                sort_no_dependencies

            fi

        fi

    done

    # try and assign tasks ready to be processed (those in no_dependencies) to a worker
    for node in ${no_dependencies[@]}; do

        # if a worker is not already working on this
        if [[ ! "${worker_task[@]}" =~ "$node" ]]; then

            # look through workers for one that is available
            for (( i=0; i<worker_num; i++ )); do
                if [[ ${worker_task[$i]} == 0 ]]; then
                    
                    # set available worker to work on $node
                    # time to finish is position in the alphabet + 60
                    ascii_value_node=$(printf '%d' "'$node")
                    ascii_value_A=$(printf '%d' "'A")
                    value=$(( ascii_value_node - ascii_value_A + 1 + 60 ))
                    worker_task[$i]=$node
                    worker_time[$i]=$value
                    break
                fi
            done

        fi

    done

done

# part 2 solution is the amount of time it took to complete all tasks
echo $time
