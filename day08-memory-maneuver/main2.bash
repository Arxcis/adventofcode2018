#!/bin/bash

# TODO: replace () () and sed with plain space-separated arrays (done so far for debugability)

# used to return stuff
ret=-1


# read input as array
input=($(</dev/stdin))


function transform_input_to_use_absolute_references() {

    local num_children=${input[$index]}

    ((index++))

    local num_metadata=${input[$index]}

    ((index++))

    # index i will store absolute reference to child number i
    local absolute_child_references=()

    # declare counter i as local (idk how to do it in the for loop)
    local i


    # for every child call this function recursively to read it
    for (( i=0; i<num_children; ++i )); do
        absolute_child_references[$(( i + 1 ))]=$index
        transform_input_to_use_absolute_references
    done

    local last_metadata_index=$(( index + num_metadata ))

    echo "index $index num_children $num_children"
    if [[ $num_children -eq 0 ]]; then
        
        # sum metadata
        echo "without nodes (index: $index)"
        local metadata_sum=0
        for (( index=index; index<last_metadata_index; ++index )); do
            metadata_sum=$(( metadata_sum + ${input[$index]} ))
            echo "index: $index,,,, $metadata_sum"
        done
        ret=$metadata_sum
        echo "reeet: $ret"

        return 1
    else
        echo "with nodes [${absolute_child_references[@]}]"
        # transform relative metadata references to absolute
        local metadata_sum=0
        for (( index=index; index<last_metadata_index; ++index )); do
            echo "--->metadatasum is $metadata_sum"
            local metadata="${input[$index]}"
            if [[ $metadata -gt 0 ]] && [[ $metadata -le $num_children ]]; then
                local child_index=${absolute_child_references[$metadata]}
                local backup_index=$index
                index=$child_index
                transform_input_to_use_absolute_references
                metadata_sum=$(( metadata_sum + ret ))
                echo "[$index] ret: $ret, $metadata_sum"
                index=$backup_index
            fi
        done
        ret=$metadata_sum
    fi
}

index=0
transform_input_to_use_absolute_references
echo "ret: $ret"


: << 'END_COMMENT'
function readNode()
    read num nodes
    read num metadata
    read each node
        readNode()
    read metadata
END_COMMENT
