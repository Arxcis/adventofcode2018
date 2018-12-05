#!/bin/bash

# Bash optimizations: 
# - https://www.tldp.org/LDP/abs/html/optimizations.html
# - https://medium.com/@bb49152/this-one-crazy-devops-language-you-should-learn-during-advent-of-code-32129ad25c01
# - subshells are the devil in Bash.. Avoid in loops!!

# PART 1

declare -A fabric_map
declare -A claim_map
claim_counter=-1
overlap_count=0
while read -r claim; do

    ((claim_counter++))

    # don't question the awk..... it works...
    # source https://kuther.net/howtos/howto-print-text-between-tags-or-characters-awk-or-sed
    claim_id=$(echo "$claim" | awk -F'[#| ]' '{print $2}')
    claim_x=$(echo "$claim" | awk -F'[@ |,]' '{print $4}')
    claim_y=$(echo "$claim" | awk -F'[,|:]' '{print $2}')
    claim_w=$(echo "$claim" | awk -F'[ |x]' '{print $4}')
    claim_h=$(echo "$claim" | awk -F'[x|$]' '{print $2}')

    # precalculate so don't have to spawn subshells in loop
    claim_xw=$(( claim_x + claim_w ))
    claim_yh=$(( claim_y + claim_h ))

    # store parsed info for part 2
    claim_map[$claim_counter,id]=$claim_id
    claim_map[$claim_counter,x1]=$claim_x
    claim_map[$claim_counter,y1]=$claim_y
    claim_map[$claim_counter,x2]=$claim_xw
    claim_map[$claim_counter,y2]=$claim_yh

    # "paint" claim on fabric, while counting overlaps
    for (( i=claim_x; i<claim_xw; i++ )); do
        for (( j=claim_y; j<claim_yh; j++ )); do
            case ${fabric_map[$i,$j]} in
                "")
                    fabric_map[$i,$j]=1
                    ;;
                1)
                    fabric_map[$i,$j]=X
                    ((overlap_count++))
                    ;;
            esac
        done
    done

done

echo $overlap_count

# PART 2

# find claim that have no X in the FABRIC_MAP
for (( i=0; i<$(( claim_counter + 1 )); i++ )); do

    does_overlap=false

    for (( j=${claim_map[$i,x1]}; j<${claim_map[$i,x2]}; j++ )); do

        # if found soltuion -> break
        # (should be part of above for conditional, but still haven't 
        #  figured out how in Bash)
        if [[ $does_overlap = true ]]; then
            break
        fi

        for (( k=${claim_map[$i,y1]}; k<${claim_map[$i,y2]}; k++ )); do
            if [[ ${fabric_map[$j,$k]} -eq X ]]; then
                does_overlap=true
                break
            fi
        done
    done

    if [[ $does_overlap = false ]]; then
        echo ${claim_map[$i,id]}
        break
    fi

done
