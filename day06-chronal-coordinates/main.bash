#!/bin/bash

# read input and remove comma and newline
input=$(</dev/stdin)
parsed_input=($(echo "$input" | sed 's/,//;s/\n//'))

# Notes from my solve:
# TODO: clean up before commit (if you're seeing this I did a booboo)
: << 'END_COMMENT'
a coordinate is finite if it does not have a coordinate on the edge of the search area

process:
* find top left, top right -> defines area to search
* for each x,y in search area find closests coordinate

* count which of the coordinates have the highest number of locations associated with them (part 1)
END_COMMENT

input_length=${#parsed_input[@]}

# determine search area
input_length=${#parsed_input[@]}

# initialize top left and bottom right to be the first coordinate
# (just to have an actual coordinate to start with, will probably be overwritten)
top_left_x=${parsed_input[0]}
top_left_y=${parsed_input[1]}
bottom_right_x=${parsed_input[0]}
bottom_right_y=${parsed_input[1]}


for (( i=0; i<input_length; i+=2 )); do
    j=$(( i + 1 ))

    my_x=${parsed_input[$i]}
    my_y=${parsed_input[$j]}

    if [[ $my_x -lt $top_left_x ]]; then top_left_x=$my_x; fi
    if [[ $my_y -lt $top_left_y ]]; then top_left_y=$my_y; fi
    if [[ $my_x -gt $bottom_right_x ]]; then bottom_right_x=$my_x; fi
    if [[ $my_y -gt $bottom_right_y ]]; then bottom_right_y=$my_y; fi

done

echo "DEBUG: $top_left_x $top_left_y $bottom_right_x $bottom_right_y"


# TODO explain
declare -A map_closest_coordinate_id

region_max=10000
inside_region_count=0

# the absolute max manhattan distance is from the top left to the bottom right.
# used as initial value of search for min
max_dist=$(( bottom_right_x - top_left_x + bottom_right_y - top_left_y ))


for (( i=top_left_x; i<=bottom_right_x; ++i)); do
    echo $i
    for (( j=top_left_y; j<=bottom_right_y; ++j )); do


        dot=-1
        min_dist=$max_dist
        total_manhattan=0
        
        for (( k=0; k<input_length; k+=2 )); do

            l=$(( k + 1 ))

            # find location of coordinate
            check_x=${parsed_input[$k]}
            check_y=${parsed_input[$l]}

            # determine manhattan distance from i,j to check_x,check_y
    
            manhattan_x_component=$(( check_x - i ))
            manhattan_y_component=$(( check_y - j ))

            # (absolute value using parameter expansion)
            manhattan=$(( ${manhattan_x_component#-} + ${manhattan_y_component#-} ))

            # if found new min dist -> update dot with id of coordinate and update min_dist
            # if found same min_dist -> update dot to be "."
            if [[ $manhattan -lt $min_dist ]]; then
                dot=$k
                min_dist=$manhattan
            elif [[ $manhattan -eq $min_dist ]]; then
                dot="."
            fi

            ((total_manhattan+=manhattan))

        done

        map_closest_coordinate_id[$i,$j]=$dot

        if [[ $total_manhattan -lt $region_max ]]; then
            ((inside_region_count++))
        fi

    done
done


# determine inifinites
# map used for lookup and uniqueness
declare -A map_infinites
for (( i=top_left_x; i<=bottom_right_x; i++ )); do
    map_infinites[${map_closest_coordinate_id[$i,$top_left_y]}]=1
    map_infinites[${map_closest_coordinate_id[$i,$bottom_right_y]}]=1
done
for (( i=top_left_y; i<=bottom_right_y; i++ )); do
    map_infinites[${map_closest_coordinate_id[$top_left_y,$i]}]=1
    map_infinites[${map_closest_coordinate_id[$bottom_right_x,$i]}]=1
done

echo "infinites: ${!map_infinites[@]}"

# finites is (all coordinates) - (infinites)
declare -A map_finites=()
for (( i = 0; i < input_length; i += 2 )); do
    if [[ -z ${map_infinites[$i]+_} ]]; then
        map_finites[$i]=0
    fi
done


# calculate area of finite coordinates
for (( i=top_left_x; i<=bottom_right_x; i++ )); do
    for (( j=top_left_y; j<=bottom_right_y; j++ )); do
        closest_coordinate="${map_closest_coordinate_id[$i,$j]}"
        if [[ ${map_finites[$closest_coordinate]+_} ]]; then
            map_finites[$closest_coordinate]=$(( map_finites[$closest_coordinate] + 1 ))
        fi
    done
done

echo "finites: "
for var in "${!map_finites[@]}"; do
    echo "$var ${map_finites[$var]}"
done

# find finite with max area
max_area=-1
for area in "${map_finites[@]}"; do
    if [[ $area -gt $max_area ]]; then
        max_area=$area
    fi
done

echo $max_area
echo $inside_region_count
