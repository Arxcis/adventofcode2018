# PSEUDOCODE
: '

for each pair i,j in 0..WIDTH,0..HEIGHT
  for each claim
    if claim involves i,j
      store that we found another claim 
    if two claims found
      break
  if found two claims
    increase overlap count


'
CLAIMS_RAW="$@"
declare -A CLAIMS_MAP

# build claim datastructure
# ( x y w h )
# (using fake assoc array https://stackoverflow.com/questions/11233825/multi-dimensional-arrays-in-bash)

CLAIMS_COUNTER=-1
while read -r CLAIM; do

    ((CLAIMS_COUNTER++))

    # don't question the awk..... it works...
    # source https://kuther.net/howtos/howto-print-text-between-tags-or-characters-awk-or-sed
    CLAIM_X=$(echo $CLAIM | awk -F'[@ |,]' '{print $4}')
    CLAIM_Y=$(echo $CLAIM | awk -F'[,|:]' '{print $2}')
    CLAIM_W=$(echo $CLAIM | awk -F'[ |x]' '{print $4}')
    CLAIM_H=$(echo $CLAIM | awk -F'[x|$]' '{print $2}')


    CLAIMS_MAP[$CLAIMS_COUNTER,x]=$CLAIM_X
    CLAIMS_MAP[$CLAIMS_COUNTER,y]=$CLAIM_Y
    CLAIMS_MAP[$CLAIMS_COUNTER,w]=$CLAIM_W
    CLAIMS_MAP[$CLAIMS_COUNTER,h]=$CLAIM_H

    echo "$CLAIM $CLAIMS_COUNTER --> ${CLAIMS_MAP[$CLAIMS_COUNTER,x]} ${CLAIMS_MAP[$CLAIMS_COUNTER,y]} ${CLAIMS_MAP[$CLAIMS_COUNTER,w]} ${CLAIMS_MAP[$CLAIMS_COUNTER,h]}"

done <<< "$CLAIMS_RAW"



NUM_CLAIMS=$CLAIMS_COUNTER
WIDTH=1000
HEIGHT=$WIDTH
OVERLAP_COUNT=0

for (( i=0; i<$WIDTH; i++ )); do

    echo "i: $i, width: $WIDTH"

    for (( j=0; j<$HEIGHT; j++ )); do
        
        CLAIM_HITS=0
        for (( k=0; k<$NUM_CLAIMS; k++ )); do

            if [[ $i -ge ${CLAIMS_MAP[$k,x]} ]] && 
               [[ $j -ge ${CLAIMS_MAP[$k,y]} ]] && 
               [[ $i -lt $(( ${CLAIMS_MAP[$k,x]} + ${CLAIMS_MAP[$k,w]} )) ]] &&
               [[ $j -lt $(( ${CLAIMS_MAP[$k,y]} + ${CLAIMS_MAP[$k,h]} )) ]]; then

                ((CLAIM_HITS++))

                if [[ $CLAIM_HITS -eq 2 ]]; then
                    echo "($i,$j) $CLAIM --> ${CLAIMS_MAP[$k,x]} ${CLAIMS_MAP[$k,y]} ${CLAIMS_MAP[$k,y]} ${CLAIMS_MAP[$k,h]} [$CLAIM_HITS] -> $k"
                    break
                fi

            fi

        done

        if [[ $CLAIM_HITS -eq 2 ]]; then
            ((OVERLAP_COUNT++))
        fi

    done

done

echo "$OVERLAP_COUNT"
