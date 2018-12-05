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

    # Alternative to below parsing of input:
    # Sed insanity -> `claim_fields_array=($(echo $claim | sed 's/#\([0-9]*\)\s@\s\([0-9]*\),\([0-9]*\):\s\([0-9]*\)x\([0-9]*\)/\1 \2 \3 \4 \5/'))`
    # parses claim into an array where fields are: 
    # i:   0,1,2,3,4
    # is: id,x,y,w,h

    # Parse claims using magic Bash parameter expansion.
    # In my testing it is faster than both sed and awk. Suspecting it 
    #   is because it doesn't need to start up a separate program
    # StackOverflow "inspiration": https://stackoverflow.com/a/13242563
    # Reference: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

    claim_id=${claim%%@*}
    claim_id=${claim_id###}

    claim_x=${claim%%,*}
    claim_x=${claim_x##*@ }

    claim_y=${claim%%:*}
    claim_y=${claim_y##*,}

    claim_w=${claim%%x*}
    claim_w=${claim_w##*:}

    claim_h=${claim##*x}

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

# increment for use in for loop
((claim_counter++))

# find claim that have no X in the FABRIC_MAP
for (( i=0; i<claim_counter; i++ )); do

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
