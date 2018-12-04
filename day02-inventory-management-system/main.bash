#!/bin/bash

# read input from stdin
INPUT=()
while read LINE; do
    INPUT+=($LINE)
done

# PART 1

# answer is eq to these two multiplied
FIRST_NUM=0
SECOND_NUM=0



for ID in ${INPUT[@]}; do

    unset COUNT
    declare -A COUNT
    for (( i=0; i<${#ID}; i++ )); do

        LETTER="${ID:$i:1}"

        # update count map
        # - if not seen yet -> make new entry with value 1
        # - if seen before -> increment
        if [ ${COUNT[$LETTER]+_} ]; then
            COUNT[$LETTER]=$(( ${COUNT[$LETTER]} + 1 ))
        else
            COUNT[$LETTER]=1
        fi

    done

    # loop through checking for twins and triplets
    HAS_TWIN=false
    HAS_TRIPLET=false
    for K in "${!COUNT[@]}"; do 

        if [[ ${COUNT[$K]} = 2 ]]; then
            HAS_TWIN=true
        fi

        if [[ ${COUNT[$K]} = 3 ]]; then
            HAS_TRIPLET=true
        fi

    done

    # update first and second num

    if [[ $HAS_TWIN = true ]]; then
        ((FIRST_NUM++))
    fi 

    if [[ $HAS_TRIPLET = true ]]; then
        ((SECOND_NUM++))
    fi 

done

echo "$(($FIRST_NUM * $SECOND_NUM ))"


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


SOLUTION_FOUND=false
IDS=(${INPUT[@]})

for (( i=0; i<${#IDS[@]}; i++ )); do

    # If found solution, stop looping
    # (this should be in the for-loop condition above, but 
    #  didn't find a way to do this :p)
    if [[ $SOLUTION_FOUND = true ]]; then
        break
    fi

    ID1=${IDS[$i]}

    # compare ID1 to every id coming after it (as ID2)
    for (( j=$(( $i + 1 )); j<${#IDS[@]}; j++ )); do

        ID2=${IDS[$j]}

        # count num different letters
        NUM_DIFF=0
        LATEST_DIFF_POS=0
        for (( k=0; k<${#ID1}; k++ )); do

            LETTER1="${ID1:$k:1}"
            LETTER2="${ID2:$k:1}"

            if [[ $LETTER1 != $LETTER2 ]]; then
                ((NUM_DIFF++))
                LATEST_DIFF_POS=$k
            fi
        done

        # if found diff of one
        if [[ $NUM_DIFF == 1 ]]; then

            # build answer by removing different character
            LEFT_ANSWER_SUBSTR=${ID1:0:$LATEST_DIFF_POS}
            RIGHT_ANSWER_SUBSTR=${ID1:$(( $LATEST_DIFF_POS + 1)):${#ID1}}

            echo "$LEFT_ANSWER_SUBSTR$RIGHT_ANSWER_SUBSTR"
            SOLUTION_FOUND=true
            break
        fi

    done

done
