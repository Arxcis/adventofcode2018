#!/bin/bash

input="$(</dev/stdin)"

declare -A track_map

next_cart_number_to_assign=0

number_of_carts=0

# IFS= to preserve leading spaces
row=0
max_length_seen=0
while IFS= read -r line; do

    #echo "$line"
    length="${#line}"

    if [[ $length -gt $max_length_seen ]]; then
        max_length_seen="$length"
    fi

    for (( col = 0; col < length; ++col )); do
        current_xy_of_input="${line:$col:1}"
        case "$current_xy_of_input" in

            " ")
                # ignore
                ;;

            \>|\<|^|v)

                ((number_of_carts++))

                underlying_track="-"
                if [[ $current_xy_of_input =~ [v|^] ]]; then
                    underlying_track="|"
                fi

                # 0|1|2
                # 0: left
                # 1: straight
                # 2: right
                track_map[$row,$col]="$current_xy_of_input 0 $underlying_track -1"

                ;;
                
            *)
                track_map[$row,$col]="$current_xy_of_input"
                ;;
        esac
        
    done

    ((row++))

done < <(echo "$input")

row_length="$row"
col_length="$max_length_seen"

echo "$row_length, $col_length"



function print_track_map() {
    local row
    local col
    for (( row = 0; row < row_length; ++row )); do
        for (( col = 0; col < col_length; ++col )); do
            local current=${track_map[$row,$col]}
            case $current in
                \<|\>|v\^)
                    array=($current)
                    printf ${array[0]}
                    ;;
                "")
                    printf " "
                    ;;
                *)
                    printf $current
            esac
        done
        echo;
    done 

}

tick=0
while [[ $number_of_carts -gt 1 ]]; do
    for (( row = 0; row < row_length; ++row )); do

        for (( col = 0; col < col_length; ++col )); do

            if [[ ${track_map[$row,$col]+_} ]]; then
                
                current="${track_map[$row,$col]}"


                if [[ $current =~ [\<\>^v] ]]; then

                    current_array=($current)

                    dir="${current_array[0]}"
                    intersection_dir="${current_array[1]}"
                    underlying_track="${current_array[2]}"
                    last_seen_tick="${current_array[3]}"


                    if [[ $last_seen_tick -lt $tick ]]; then

                        #echo "found cart! $row,$col $dir,$intersection_dir $underlying_track $last_seen_tick"
                        
                        # determine next pos
                        next_row=$row
                        next_col=$col
                        case $dir in
                            \<)
                                ((next_col--))
                                ;;
                            \>)
                                ((next_col++))
                                ;;
                            ^)
                                ((next_row--))
                                ;;
                            v)
                                ((next_row++))
                                ;;
                        esac


                        
                        # store next underlying track
                        next_underlying_track="${track_map[$next_row,$next_col]}"

                        # look ahead 
                        next_dir=$dir
                        next_intersection_dir=$intersection_dir
                        collision_found=false
                        case $next_underlying_track in
                            -|\|)
                                # do nothing
                                ;;
                            /)
                                case $dir in
                                    \<)
                                        next_dir="v"
                                        ;;
                                    \>)
                                        next_dir="^"
                                        ;;
                                    ^)
                                        next_dir=">"
                                        ;;
                                    v)
                                        next_dir="<"
                                    ;;
                                esac
                                ;;
                            \\)
                                case $dir in
                                    \<)
                                        next_dir="^"
                                        ;;
                                    \>)
                                        next_dir="v"
                                        ;;
                                    ^)
                                        next_dir="<"
                                        ;;
                                    v)
                                        next_dir=">"
                                        ;;
                                esac
                                ;;
                            +)

                                case $intersection_dir in
                                    0)
                                        case $dir in
                                            \<)
                                                next_dir="v"
                                                ;;
                                            \>)
                                                next_dir="^"
                                                ;;
                                            ^)
                                                next_dir="<"
                                                ;;
                                            v)
                                                next_dir=">"
                                            ;;
                                        esac
                                        
                                        ;;
                                    1)
                                        # go straight, so do nothing
                                        ;;
                                    2)
                                        case $dir in
                                            \<)
                                                next_dir="^"
                                                ;;
                                            \>)
                                                next_dir="v"
                                                ;;
                                            ^)
                                                next_dir=">"
                                                ;;
                                            v)
                                                next_dir="<"
                                            ;;
                                        esac
                                        ;;
                                esac

                                ((next_intersection_dir++))
                                if [[ $next_intersection_dir -gt 2 ]]; then
                                    next_intersection_dir=0
                                fi


                                

                                ;;
                                *)
                                    echo "COLLISION AT $next_col,$next_row"
                                    collision_found=true
                                    ((number_of_carts-=2))
                                    ;;
                        esac

                        if $collision_found; then
                            track_map[$row,$col]="$underlying_track"
                            next_underlying_track=($next_underlying_track)
                            next_underlying_track=${next_underlying_track[2]}
                            track_map[$next_row,$next_col]="$next_underlying_track"
                        else
                            track_map[$row,$col]="$underlying_track"
                            track_map[$next_row,$next_col]="$next_dir $next_intersection_dir $next_underlying_track $tick"
                        fi

                        


                        #echo "NEXT for cart! $next_row,$next_col $next_dir,$next_intersection_dir $next_underlying_track $tick"


                    fi

                fi

            fi
            
        done

    done

    if [[ $number_of_carts -eq 1 ]]; then
        for xy in "${!track_map[@]}"; do
            if [[ ${track_map[$xy]} =~ [\<\>^v] ]]; then
                echo "${xy#*,},${xy%,*}"
            fi
        done
    fi

    #print_track_map

    #sleep .2
    echo "--------- $tick $number_of_carts"
    ((tick++))
done


: << 'END'

# will need per-cart memory
# remove carts from input?

look for carts and assign each a number
store cart info in map(s)

pos_map
next_intersection_direction_map[<cart_number>]=[left|straight|right]
left, straight, right, REPEAT

for each row
    find next cart
    figure out cart number by looking up in position map (?)
    advance cart
    if collision
        output x,y


END
