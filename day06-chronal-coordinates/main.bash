#!/bin/bash

# read input and remove comma and newline
input=$(</dev/stdin)
parsed_input=($(echo "$input" | sed 's/,//;s/\n//'))

# Notes from my solve:
: << 'END_COMMENT'
a coordinate is finite if there exists another coordinate with:
* lower x
* higher x
* lower y
* higher y

process:
* find finite coordinates.
* find top left, top right.
* fill out grid from top left to top right, 
  while keeping track of coordinates with a total manhattan distance less than $region_max (part 2)
* count which of the coordinates have the highest number of locations associated with them (part 1)
END_COMMENT

length=${#parsed_input[@]}

# initialize top left and bottom right to be the first coordinate
# (just to have an actual coordinate to start with, will probably be overwritten)
top_left_x=${parsed_input[0]}
top_left_y=${parsed_input[1]}
bottom_right_x=${parsed_input[0]}
bottom_right_y=${parsed_input[1]}

# find finite coordinates, and add them to the $finite_coordinate_ids array
# (see heredoc at top for logic)
# (this section could probably be sped up if some IQ is applied :p)
finite_coordinate_ids=()
for (( i=0; i<length; i+=2 )); do
    j=$(( i + 1 ))

    my_x=${parsed_input[$i]}
    my_y=${parsed_input[$j]}

    lower_x=false
    lower_y=false
    higher_x=false
    higher_y=false

    for (( k=0; k<length; k+=2 )); do
        l=$(( k + 1 ))

        check_x=${parsed_input[$k]}
        check_y=${parsed_input[$l]}

        if [[ $check_x -lt $my_x ]]; then lower_x=true; fi
        if [[ $check_x -gt $my_x ]]; then higher_x=true; fi
        if [[ $check_y -lt $my_y ]]; then lower_y=true; fi
        if [[ $check_y -gt $my_y ]]; then higher_y=true; fi

    done

    if [[ $lower_x = true ]] &&
       [[ $lower_y = true ]] &&
       [[ $higher_x = true ]] &&
       [[ $higher_y = true ]]; then

        finite_coordinate_ids+=($i)

    else

        if [[ $my_x -lt $top_left_x ]]; then top_left_x=$my_x; fi
        if [[ $my_y -lt $top_left_y ]]; then top_left_y=$my_y; fi
        if [[ $my_x -gt $bottom_right_x ]]; then bottom_right_x=$my_x; fi
        if [[ $my_y -gt $bottom_right_y ]]; then bottom_right_y=$my_y; fi

    fi

done


# map is used as a fake two-dimentional array. value map[i,j] ends up holding either the id of the coordinate 
# that is closest, or a "." if multiple coordinates are closest
declare -A map

# the absolute max manhattan distance is from the top left to the bottom right.
# used as initial value of search for min
max_dist=$(( bottom_right_x -top_left_x + bottom_right_y - top_left_y ))

# used for part 2
region_max=10000
inside_region_count=0

# loop from top left to bottom right and fill map with values.
for (( i=top_left_x; i<=bottom_right_x; i++ )); do
    for (( j=top_left_y; j<=bottom_right_y; j++ )); do

        # determine dot
        dot=-1
        min_dist=$max_dist
        
        total_manhattan=0
        for (( k=0; k<length; k+=2 )); do

            l=$(( k + 1 ))

            # find location of coordinate
            check_x=${parsed_input[$k]}
            check_y=${parsed_input[$l]}

            # determine manhattan distance from i,j to check_x,check_y
    
            manhattan_x_component=$(( check_x - i ))
            manhattan_y_component=$(( check_y - j ))
            if [[ $manhattan_x_component -lt 0 ]]; then manhattan_x_component=$(( 0 - manhattan_x_component )); fi
            if [[ $manhattan_y_component -lt 0 ]]; then manhattan_y_component=$(( 0 - manhattan_y_component )); fi 
            manhattan=$(( manhattan_x_component + manhattan_y_component ))

            # (for part 2)
            ((total_manhattan+=$manhattan))

            # if found new min dist -> update dot with id of coordinate and update min_dist
            # if found same min_dist -> update dot to be "."
            if [[ $manhattan -lt $min_dist ]]; then
                dot=$k
                min_dist=$manhattan
            elif [[ $manhattan -eq $min_dist ]]; then
                dot="."
            fi

        done

        map[$i,$j]=$dot

        if [[ $total_manhattan -lt $region_max ]]; then
            ((inside_region_count++))
        fi

    done
done

# store answer for part 2
# (answer is number of locations that have a total manhattan distance to 
#  all coordinates less than $region_max)
part_2_answer=$inside_region_count

# find finite with most locations on map
max_id=-1
max_val=0
for id in "${finite_coordinate_ids[@]}"; do

    count=0
    for (( i=top_left_x; i<=bottom_right_x; i++ )); do
        for (( j=top_left_y; j<=bottom_right_y; j++ )); do
            if [[ "$id" == "${map[$i,$j]}" ]]; then
                ((count++))
            fi
        done
    done

    if [[ $count -gt $max_val ]]; then
        max_id=$id
        max_val=$count
    fi
done

# part 1 answer is the size of the largest region
part_1_answer=$max_val

echo $part_1_answer
echo $part_2_answer
