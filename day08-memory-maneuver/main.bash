#!/bin/bash

### Notes around solution:
#
# * Bash has three ways to handle return values from functions: using a return statement 
#   (limited to 0 to 255..), using a subshell with echo, and avoiding subshells and using global 
#   variables. All of these are bad.. The first option is out of question, the second is less 
#   performant because it requires subshells (recursively!), and the third uses global variables. 
#   This solution uses global variables without subshells for performance reasons. 
#   http://rus.har.mn/blog/2010-07-05/subshells/
# * "ret" is a global variable that contains the return value of any function call. Because of 
#   this all function calls are immediately followed up by checking the contents of this variable.


# read input as array
input_array=($(</dev/stdin))

# This variable is used to hold the position in the input_array at any point. 
# Both of the recursive functions use it
index=-1

# This variable is used to hold the return value of function calls, since Bash only 
# allows return values 0 to 255..
ret=-1

###############################################################################
### PART 1 FUNCTION
###
### * Recursively traverses the tree to count up the sum of metadata fields
### * Uses the global variables index, ret
###############################################################################
function sum_up_metadata() {

    # sum to be returned
    local metadata_sum=0

    # read number of children and number of metadata while advancing index
    local num_children=${input_array[$index]}
    ((index++))
    local num_metadata=${input_array[$index]}
    ((index++))

    # declare counter i as local (idk how to do it in the for loop)
    local i

    for (( i=0; i<num_children; ++i )); do

        # call this function
        sum_up_metadata

        # increase metadata_sum by value of child
        metadata_sum=$(( metadata_sum + ret ))
        
    done

    local last_metadata_index=$(( index + num_metadata ))

    # add value of metadata value fields to sum
    for (( index=index; index<last_metadata_index; ++index )); do
        local metadata=${input_array[$index]}
        metadata_sum=$(( metadata_sum + metadata ))
    done

    ret=$metadata_sum
}


###############################################################################
### PART 2 FUNCTION
###
### * Recursively traverses tree to find value of a given node as. Value of 
###   node is defined in the task description
### * Uses global variables index, ret
###############################################################################
function value_of_node() {

    # read number of children and number of metadata while advancing index
    local num_children=${input_array[$index]}
    ((index++))
    local num_metadata=${input_array[$index]}
    ((index++))

    # index i will store value of child i
    local child_values=()

    # declare counter i as local (idk how to do it in the for loop)
    local i

    # Call this function recursively for every child while storing it's value for later
    for (( i=0; i<num_children; ++i )); do

        # prevent unnecessary subshell later by storing i+1
        local i_plus_one=$(( i + 1 ))

        # call this function
        value_of_node
        
        # store value (value now in $ret)
        child_values[$i_plus_one]=$ret
    done

    # store index of last metadata field (to be used in for loops below)
    local last_metadata_index=$(( index + num_metadata ))

    # if no children -> value of node is the sum of metadata entries
    # otherwise      -> value of node is sum of values of children references in metadata
    if [[ $num_children -eq 0 ]]; then
        
        # sum up value of metadata fields
        local metadata_sum=0
        for (( index=index; index<last_metadata_index; ++index )); do
            metadata_sum=$(( metadata_sum + ${input_array[$index]} ))
        done

        ret=$metadata_sum

    else

        # sum up value of each child referenced in metadata
        local metadata_sum=0
        for (( index=index; index<last_metadata_index; ++index )); do
            local metadata="${input_array[$index]}"
            if [[ $metadata -gt 0 ]] && [[ $metadata -le $num_children ]]; then
                child_value=${child_values[$metadata]} 
                metadata_sum=$(( metadata_sum + child_value ))
            fi
        done

        ret=$metadata_sum

    fi
}


# use defined functions to calculate answers. Remember index defines the starting point of 
# each function, and ret contains the returned value

# PART 1

index=0
sum_up_metadata
echo "$ret"

# PART 2

index=0
value_of_node
echo "$ret"
