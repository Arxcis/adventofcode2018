#!/bin/bash

# read input from stdin
input=()
while read -r line; do
    input+=($line)
done

# PART 1

# answer is eq to these two multiplied
first_num=0
second_num=0


for id in "${input[@]}"; do

    unset count
    declare -A count
    for (( i=0; i<${#id}; i++ )); do

        letter="${id:$i:1}"

        # update count map
        # - if not seen yet -> make new entry with value 1
        # - if seen before -> increment
        if [ "${count[$letter]+_}" ]; then
            count[$letter]=$(( ${count[$letter]} + 1 ))
        else
            count[$letter]=1
        fi

    done

    # loop through checking for twins and triplets
    has_twin=false
    has_triplet=false
    for k in "${!count[@]}"; do 

        if [[ ${count[$k]} = 2 ]]; then
            has_twin=true
        fi

        if [[ ${count[$k]} = 3 ]]; then
            has_triplet=true
        fi

    done

    # update first and second num

    if [[ $has_twin = true ]]; then
        ((first_num++))
    fi 

    if [[ $has_triplet = true ]]; then
        ((second_num++))
    fi 

done

echo "$(( first_num * second_num ))"


# PART 2


# PSEUDOCODE (since Bash is nsfw)
# for each ID
#   if solution found
#     break
#   for each later ID
#     for each letter
#       if is different
#         increment diff count
#         store diff pos
#     if diff count is two
#       remove character at diff pos
#       output answer


solution_found=false
ids=(${input[@]})

for (( i=0; i<${#ids[@]}; i++ )); do

    # If found solution, stop looping
    # (this should be in the for-loop condition above, but 
    #  didn't find a way to do this :p)
    if [[ $solution_found = true ]]; then
        break
    fi

    id1=${ids[$i]}

    # compare ID1 to every id coming after it (as ID2)
    for (( j=$(( i + 1 )); j<${#ids[@]}; j++ )); do

        id2=${ids[$j]}

        # count num different letters
        num_diff=0
        latest_diff_pos=0
        for (( k=0; k<${#id1}; k++ )); do

            letter1="${id1:$k:1}"
            letter2="${id2:$k:1}"

            if [[ $letter1 != "$letter2" ]]; then
                ((num_diff++))
                latest_diff_pos=$k
            fi
        done

        # if found diff of one
        if [[ $num_diff == 1 ]]; then

            # build answer by removing different character
            left_answer_substr=${id1:0:$latest_diff_pos}
            right_answer_substr=${id1:$(( latest_diff_pos + 1)):${#id1}}

            echo "$left_answer_substr$right_answer_substr"
            solution_found=true
            break
        fi

    done

done
