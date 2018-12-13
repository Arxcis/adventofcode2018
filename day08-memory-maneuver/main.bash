#!/bin/bash

# TODO: 
# * replace () () and sed with plain space-separated arrays (done so far for debugability)
# * clean up variable (funtion as well naming)
# * http://rus.har.mn/blog/2010-07-05/subshells/

# read input as array
input=($(</dev/stdin))

function sum_metadata_for_node() {

    local index=$1

    local dbg=''

    local sum=0

    local num_children=${input[$index]}

    ((index++))

    local num_metadata=${input[$index]}

    ((index++))

    # declare counter i as local (idk how to do it in the for loop)
    local i

    # for every child call this function recursively to read it
    for (( i=0; i<num_children; ++i )); do
        
        child_ret=($(echo "$(sum_metadata_for_node $index)" | sed 's/(\([[:digit:]]*\)) (\([[:digit:]]*\))/\1 \2/'))
        child_sum=${child_ret[0]}
        child_index=${child_ret[1]}
        index=$(( child_index ))
        dbg+="[$index (added) $child_index]"
    done



    # add up metadata
    last_metadata_index=$(( index + num_metadata ))
    for (( index=index; index<last_metadata_index; ++index )); do
        metadata="${input[$index]}"
        sum=$(( sum + metadata ))
    done

    echo "($sum) ($index) $dbg"
}

echo "$(sum_metadata_for_node 0)"

: << 'END_COMMENT'
function readNode()
    read num nodes
    read num metadata
    read each node
        readNode()
    read metadata
END_COMMENT
