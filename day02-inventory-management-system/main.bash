FIRST_NUM=0
SECOND_NUM=0

for ID in "$@"; do

    #echo "id: $ID"
    

    unset COUNT
    declare -A COUNT
    for (( i=0; i<${#ID}; i++ )); do

        LETTER="${ID:$i:1}"

        if [ ${COUNT[$LETTER]+_} ]; then
            COUNT[$LETTER]=$(( ${COUNT[$LETTER]} + 1 ))
        else
            COUNT[$LETTER]=1
        fi

    done

    HAS_TWIN=false
    HAS_TRIPLET=false
    for K in "${!COUNT[@]}"; do 
        if [[ ${COUNT[$K]} = 2 ]]; then
            HAS_TWIN=true
        fi

        if [[ ${COUNT[$K]} = 3 ]]; then
            HAS_TRIPLET=true
        fi

        #echo "$K: ${COUNT[$K]}"
    done

    if [[ $HAS_TWIN = true ]]; then
        ((SECOND_NUM++))
    fi 

    if [[ $HAS_TRIPLET = true ]]; then
        ((FIRST_NUM++))
    fi 

    #echo "twin: $HAS_TWIN"
    #echo "triplet: $HAS_TRIPLET"
done

echo "$(($FIRST_NUM * $SECOND_NUM ))"
