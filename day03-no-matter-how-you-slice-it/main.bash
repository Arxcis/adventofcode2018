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
CLAIMS="$@"



WIDTH=20
HEIGHT=$WIDTH
OVERLAP_COUNT=0

for (( i=0; i<$WIDTH; i++ )); do

    for (( j=0; j<$HEIGHT; j++ )); do
        
        CLAIM_HITS=0
        while read -r CLAIM && [[ $CLAIM_HITS -ne 2 ]]; do

            # don't question the awk..... it works...
            # source https://kuther.net/howtos/howto-print-text-between-tags-or-characters-awk-or-sed
            CLAIM_X=$(echo $CLAIM | awk -F'[@ |,]' '{print $4}')
            CLAIM_Y=$(echo $CLAIM | awk -F'[,|:]' '{print $2}')
            CLAIM_W=$(echo $CLAIM | awk -F'[ |x]' '{print $4}')
            CLAIM_H=$(echo $CLAIM | awk -F'[x|$]' '{print $2}')

            #echo "($i,$j) $CLAIM --> $CLAIM_X $CLAIM_Y $CLAIM_W $CLAIM_H"


            if [[ $i -ge $CLAIM_X ]] && 
               [[ $j -ge $CLAIM_Y ]] && 
               [[ $i -lt $(( $CLAIM_X + $CLAIM_W )) ]] &&
               [[ $j -lt $(( $CLAIM_Y + $CLAIM_H )) ]]; then

                ((CLAIM_HITS++))

                if [[ $CLAIM_HITS -eq 2 ]]; then
                    echo "($i,$j) $CLAIM --> $CLAIM_X $CLAIM_Y $CLAIM_W $CLAIM_H [$CLAIM_HITS]"
                fi

            fi


        done <<< "$CLAIMS"

        if [[ $CLAIM_HITS -eq 2 ]]; then
            ((OVERLAP_COUNT++))
        fi

    done

done

echo "$OVERLAP_COUNT"
