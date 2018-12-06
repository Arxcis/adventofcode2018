#!/bin/bash

# read input and remove comma and newline
input=$(</dev/stdin)
parsed_input=($(echo "$input" | sed 's/,//;s/\n//'))

#...now what

: << 'END_COMMENT'

is finite if:
    there exists other coordinate with:
        x lower
        x higher
        y lower
        y higher


process:
    find finite coordinates.
    find top left, top right.
    fill out grid from top left to top right :p
    count which of the coordinates have the highest number of locations associated with them
END_COMMENT

length=${#parsed_input[@]}
top_left_x=${parsed_input[0]}
top_left_y=${parsed_input[1]}
bottom_right_x=${parsed_input[0]}
bottom_right_y=${parsed_input[1]}
finite_coordinate_ids=()
for (( i=0; i<length; i+=2 )); do
    j=$(( i + 1 ))

    my_x=${parsed_input[$i]}
    my_y=${parsed_input[$j]}

    echo "$i,$j -> $my_x,$my_y"

    lower_x=false
    lower_y=false
    higher_x=false
    higher_y=false

    for (( k=0; k<length; k+=2 )); do
        l=$(( k + 1 ))

        check_x=${parsed_input[$k]}
        check_y=${parsed_input[$l]}

        echo "--$k,$l -> $check_x,$check_y"

        if [[ $check_x -lt $my_x ]]; then lower_x=true; fi
        if [[ $check_x -gt $my_x ]]; then higher_x=true; fi
        if [[ $check_y -lt $my_y ]]; then lower_y=true; fi
        if [[ $check_y -gt $my_y ]]; then higher_y=true; fi

    done

    if [[ $lower_x = true ]] &&
       [[ $lower_y = true ]] &&
       [[ $higher_x = true ]] &&
       [[ $higher_y = true ]]; then

        echo "--I'M FINITE!!"
        finite_coordinate_ids+=($i)

    else

        if [[ $my_x -lt $top_left_x ]]; then top_left_x=$my_x; fi
        if [[ $my_y -lt $top_left_y ]]; then top_left_y=$my_y; fi
        if [[ $my_x -gt $bottom_right_x ]]; then bottom_right_x=$my_x; fi
        if [[ $my_y -gt $bottom_right_y ]]; then bottom_right_y=$my_y; fi

    fi

done

echo "tl: $top_left_x,$top_left_y, br: $bottom_right_x,$bottom_right_y, finites: ${finite_coordinate_ids[@]}"

# loop from top left to bottom right, filling out nodes
declare -A map
max_dist=$(( bottom_right_x -top_left_x + bottom_right_y - top_left_y ))
echo "absolute max: $max_dist"
for (( i=top_left_x; i<=bottom_right_x; i++ )); do
    echo "$i...$bottom_right_x"
    for (( j=top_left_y; j<=bottom_right_y; j++ )); do

        # determine dot
        dot=notavalidthing
        min_dist=$max_dist
        for (( k=0; k<length; k+=2 )); do

            l=$(( k + 1 ))

            check_x=${parsed_input[$k]}
            check_y=${parsed_input[$l]}

            manhattan_x_component=$(( check_x - i ))
            manhattan_y_component=$(( check_y - j ))

            if [[ $manhattan_x_component -lt 0 ]]; then 
                manhattan_x_component=$(( 0 - manhattan_x_component ))
            fi

            if [[ $manhattan_y_component -lt 0 ]]; then 
                manhattan_y_component=$(( 0 - manhattan_y_component ))
            fi

            manhattan=$(( manhattan_x_component + manhattan_y_component ))

            #echo "--> $i,$j $check_x,$check_y -> man: $manhattan"

            if [[ $manhattan -lt $min_dist ]]; then
                dot=$k
                min_dist=$manhattan
                #echo "found new smallest dist -> $dot, man: $manhattan"
            elif [[ $manhattan -eq $min_dist ]]; then
                #echo "same dist"
                dot="."
            fi


            map[$i,$j]=$dot

        done

    done
done

# draw for debug
#for (( i=top_left_x; i<=bottom_right_x; i++ )); do
#    for (( j=top_left_y; j<=bottom_right_y; j++ )); do
#
#        printf "${map[$i,$j]}\t"
#
#    done
#    echo
#done

echo "here"
           
# find finite with most locations on map
max_id=notavalidthing
max_val=0
for id in "${finite_coordinate_ids[@]}"; do
    echo "$id ${#finite_coordinate_ids[@]}"

    count=0
    for (( i=top_left_x; i<=bottom_right_x; i++ )); do
        for (( j=top_left_y; j<=bottom_right_y; j++ )); do
            
            #echo "$id - ${map[$i,$j]}"
            if [[ "$id" == "${map[$i,$j]}" ]]; then
                ((count++))
                #echo "koko"
            fi

        done
    done

    if [[ $count -gt $max_val ]]; then
        max_id=$id
        max_val=$count
    fi
done

echo $max_val
