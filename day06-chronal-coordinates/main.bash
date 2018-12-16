#!/bin/bash

# read input and remove comma and newline
input=$(</dev/stdin)
parsed_input=($(echo "$input" | sed 's/,//;s/\n//'))

# store length of parsed input
parsed_input_length=${#parsed_input[@]}

# stores the bounds of the area to search
# initialize top left and bottom right to be the first coordinate
# (just to have an actual coordinate to start with, will probably be overwritten)
top_left_x=${parsed_input[0]}
top_left_y=${parsed_input[1]}
bottom_right_x=${parsed_input[0]}
bottom_right_y=${parsed_input[1]}

# determine bounds of search area
for (( i=0; i<parsed_input_length; i+=2 )); do
    j=$(( i + 1 ))

    my_x=${parsed_input[$i]}
    my_y=${parsed_input[$j]}

    if [[ $my_x -lt $top_left_x ]]; then top_left_x=$my_x; fi
    if [[ $my_y -lt $top_left_y ]]; then top_left_y=$my_y; fi
    if [[ $my_x -gt $bottom_right_x ]]; then bottom_right_x=$my_x; fi
    if [[ $my_y -gt $bottom_right_y ]]; then bottom_right_y=$my_y; fi

done

# map is used as a fake two-dimentional array. value map[i,j] ends up holding either the id of the 
# coordinate that is closest, or a "." if multiple coordinates are closest
declare -A map_closest_coordinate_id

region_max=10000
inside_region_count=0

# the absolute max manhattan distance is from the top left to the bottom right.
# used as initial value of search for min
max_dist=$(( bottom_right_x - top_left_x + bottom_right_y - top_left_y ))

# fill out map_closest_coordinate_id and determine inside_region_count by traversing search area 
# while calculating manhattan distances to coordinates and determining closests coordinate
for (( i=top_left_x; i<=bottom_right_x; ++i)); do
    for (( j=top_left_y; j<=bottom_right_y; ++j )); do

        dot=-1
        min_dist=$max_dist
        total_manhattan=0
        
        for (( k=0; k<parsed_input_length; k+=2 )); do

            l=$(( k + 1 ))

            # find location of coordinate
            check_x=${parsed_input[$k]}
            check_y=${parsed_input[$l]}

            # determine manhattan distance from i,j to check_x,check_y
            # (param expansion used to find absolute value)
            manhattan_x_component=$(( check_x - i ))
            manhattan_y_component=$(( check_y - j ))
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

        # if the sum of manhattan distances is less than the maximum to be considered inside the 
        # (part 2) region we count this location to be inside the region
        if [[ $total_manhattan -lt $region_max ]]; then
            ((inside_region_count++))
        fi

    done
done


# coordinates that have a location on the border of the search area that has it as it's closest 
# coordinate is considered infinite
# (map used as set. value (1) never used)
declare -A map_infinites
for (( i=top_left_x; i<=bottom_right_x; i++ )); do
    map_infinites[${map_closest_coordinate_id[$i,$top_left_y]}]=1
    map_infinites[${map_closest_coordinate_id[$i,$bottom_right_y]}]=1
done
for (( i=top_left_y; i<=bottom_right_y; i++ )); do
    map_infinites[${map_closest_coordinate_id[$top_left_y,$i]}]=1
    map_infinites[${map_closest_coordinate_id[$bottom_right_x,$i]}]=1
done

# determine finites. a coordinate is finite if it is not infinite (is not in map_infinites)
declare -A map_finites=()
for (( i = 0; i < parsed_input_length; i += 2 )); do
    if [[ -z ${map_infinites[$i]+_} ]]; then
        map_finites[$i]=0
    fi
done

# ("." could appear in finites. remove just to be sure)
unset 'map_finites[.]'

# calculate area of finite coordinates
for (( i=top_left_x; i<=bottom_right_x; i++ )); do
    for (( j=top_left_y; j<=bottom_right_y; j++ )); do
        closest_coordinate="${map_closest_coordinate_id[$i,$j]}"
        if [[ ${map_finites[$closest_coordinate]+_} ]]; then
            map_finites[$closest_coordinate]=$(( map_finites[\$closest_coordinate] + 1 ))
        fi
    done
done

# find finite with max area for part 1
max_area=-1
for area in "${map_finites[@]}"; do
    if [[ $area -gt $max_area ]]; then
        max_area=$area
    fi
done

echo "$max_area"
echo "$inside_region_count"
