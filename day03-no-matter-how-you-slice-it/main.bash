#!/bin/bash

# Bash optimizations: 
# - https://www.tldp.org/LDP/abs/html/optimizations.html
# - https://medium.com/@bb49152/this-one-crazy-devops-language-you-should-learn-during-advent-of-code-32129ad25c01
# - subshells are the devil in Bash.. Avoid in loops!!

# PART 1

declare -A FABRIC_MAP
declare -A CLAIM_MAP
CLAIM_COUNTER=-1
OVERLAP_COUNT=0
while read -r CLAIM; do


    ((CLAIM_COUNTER++))


    # don't question the awk..... it works...
    # source https://kuther.net/howtos/howto-print-text-between-tags-or-characters-awk-or-sed
    CLAIM_ID=$(echo $CLAIM | awk -F'[#| ]' '{print $2}')
    CLAIM_X=$(echo $CLAIM | awk -F'[@ |,]' '{print $4}')
    CLAIM_Y=$(echo $CLAIM | awk -F'[,|:]' '{print $2}')
    CLAIM_W=$(echo $CLAIM | awk -F'[ |x]' '{print $4}')
    CLAIM_H=$(echo $CLAIM | awk -F'[x|$]' '{print $2}')

    # precalculate so don't have to spawn subshells in loop
    CLAIM_XW=$(( $CLAIM_X + $CLAIM_W ))
    CLAIM_YH=$(( $CLAIM_Y + $CLAIM_H ))

    # store parsed info for part 2
    CLAIM_MAP[$CLAIM_COUNTER,id]=$CLAIM_ID
    CLAIM_MAP[$CLAIM_COUNTER,x1]=$CLAIM_X
    CLAIM_MAP[$CLAIM_COUNTER,y1]=$CLAIM_Y
    CLAIM_MAP[$CLAIM_COUNTER,x2]=$CLAIM_XW
    CLAIM_MAP[$CLAIM_COUNTER,y2]=$CLAIM_YH

    # "paint" claim on fabric, while counting overlaps
    for (( i=$CLAIM_X; i<$CLAIM_XW; i++ )); do
        for (( j=$CLAIM_Y; j<$CLAIM_YH; j++ )); do
            case ${FABRIC_MAP[$i,$j]} in
                "")
                    FABRIC_MAP[$i,$j]=1
                    ;;
                1)
                    FABRIC_MAP[$i,$j]=X
                    ((OVERLAP_COUNT++))
                    ;;
                X)
                    ;;
            esac
        done
    done

done

echo $OVERLAP_COUNT

# PART 2

# find claim that have no X in the FABRIC_MAP
for (( i=0; i<$(( CLAIM_COUNTER + 1 )); i++ )); do

    DOES_OVERLAP=false

    for (( j=${CLAIM_MAP[$i,x1]}; j<${CLAIM_MAP[$i,x2]}; j++ )); do

        # if found soltuion -> break
        # (should be part of above for conditional, but still haven't 
        #  figured out how in Bash)
        if [[ $DOES_OVERLAP = true ]]; then
            break
        fi

        for (( k=${CLAIM_MAP[$i,y1]}; k<${CLAIM_MAP[$i,y2]}; k++ )); do
            if [[ ${FABRIC_MAP[$j,$k]} -eq X ]]; then
                DOES_OVERLAP=true
                break
            fi
        done
    done

    if [[ $DOES_OVERLAP = false ]]; then
        echo ${CLAIM_MAP[$i,id]}
        break
    fi

done
