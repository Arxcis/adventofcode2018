#!/bin/bash

# Bash optimizations: 
# - https://www.tldp.org/LDP/abs/html/optimizations.html
# - https://medium.com/@bb49152/this-one-crazy-devops-language-you-should-learn-during-advent-of-code-32129ad25c01
# EUREKA!!! subshells are the devil in Bash.. Avoid in loops :D

# PART 1

declare -A FABRIC_MAP
CLAIM_COUNTER=-1
while read -r CLAIM; do

    ((CLAIM_COUNTER++))


    # don't question the awk..... it works...
    # source https://kuther.net/howtos/howto-print-text-between-tags-or-characters-awk-or-sed
    CLAIM_X=$(echo $CLAIM | awk -F'[@ |,]' '{print $4}')
    CLAIM_Y=$(echo $CLAIM | awk -F'[,|:]' '{print $2}')
    CLAIM_W=$(echo $CLAIM | awk -F'[ |x]' '{print $4}')
    CLAIM_H=$(echo $CLAIM | awk -F'[x|$]' '{print $2}')

    # precalculate so don't have to spawn subshells in loop
    CLAIM_XW=$(( $CLAIM_X + $CLAIM_W ))
    CLAIM_YH=$(( $CLAIM_Y + $CLAIM_H ))

    for (( i=$CLAIM_X; i<$CLAIM_XW; i++ )); do
        for (( j=$CLAIM_Y; j<$CLAIM_YH; j++ )); do
            if [[ ${FABRIC_MAP[$i,$j]+_} ]]; then
                FABRIC_MAP[$i,$j]=X
            else
                FABRIC_MAP[$i,$j]=1
            fi
        done
    done

done

# count overlaps
OVERLAP_COUNT=0
for DOT in ${FABRIC_MAP[@]}; do
    if [[ $DOT -eq X ]]; then
        ((OVERLAP_COUNT++))
    fi
done

echo $OVERLAP_COUNT
