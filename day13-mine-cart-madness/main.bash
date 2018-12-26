#!/bin/bash

###############################################################################
### UTIL
###############################################################################

number_of_carts=0
cart_pos_row=()
cart_pos_col=()
next_cart_number_to_assign=0

function sort_cart_pos() {

    local i
    local j

    # sort by row and col (so that looping through the arrays read from left 
    # to right, top to bottom)
    for (( i = 0; i < number_of_carts; ++i )); do
        local min_index=$i
        for (( j = i + 1; j < number_of_carts; ++j )); do
            if [[ ${cart_pos_row[$j]} -le ${cart_pos_row[$min_index]} ]] &&
               [[ ${cart_pos_col[$j]} -lt ${cart_pos_col[$min_index]} ]]; then
                min_index=$j
            fi
        done

        local tmp=${cart_pos_row[$i]}
        cart_pos_row[$i]=${cart_pos_row[$min_index]}
        cart_pos_row[$min_index]=$tmp

        local tmp=${cart_pos_col[$i]}
        cart_pos_col[$i]=${cart_pos_col[$min_index]}
        cart_pos_col[$min_index]=$tmp

    done

}

###############################################################################
### PARSE INPUT
###############################################################################

input="$(</dev/stdin)"

declare -A track_map

# IFS= to preserve leading spaces
row=0
max_length_seen=0
while IFS= read -r line; do

    line_length="${#line}"

    # keep track of maximum width of input (even though is probably consistent)
    if [[ $line_length -gt $max_length_seen ]]; then
        max_length_seen="$line_length"
    fi

    for (( col = 0; col < line_length; ++col )); do
        current_xy_of_input="${line:$col:1}"
        case "$current_xy_of_input" in

            " ")
                # ignore
                ;;

            \>|\<|^|v)

                cart_pos_row+=($row)
                cart_pos_col+=($col)

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

echo "${cart_pos_row[@]}"
echo "${cart_pos_col[@]}"




tick=0
while [[ $number_of_carts -gt 1 ]]; do

    for (( i = 0; i < number_of_carts; ++i )); do

            row=${cart_pos_row[$i]}
            col=${cart_pos_col[$i]}
            #echo "fetched $row,$col and i is $i"

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
                                    echo "COLLISION AT $next_row,$next_col"
                                    collision_found=true
                                    ;;
                        esac

                        if $collision_found; then

                            for (( pos_i = i; pos_i < number_of_carts - 1; ++pos_i )); do
                                cart_pos_row[$pos_i]=${cart_pos_row[$(( pos_i + 1 ))]} 
                                cart_pos_col[$pos_i]=${cart_pos_col[$(( pos_i + 1 ))]} 
                            done
                            unset "cart_pos_row[$(( pos_length - 1))]"
                            unset "cart_pos_col[$(( pos_length - 1))]"
                            pos_length="${#cart_pos_row[@]}"
                            echo "POSLENGTH NOW $pos_length"
                            ((--i))

                            to_delete=-1
                            for (( pos_i = 0; pos_i < number_of_carts; ++pos_i )); do
                                if [[ ${cart_pos_row[$pos_i]} -eq $next_row ]] &&
                                   [[ ${cart_pos_col[$pos_i]} -eq $next_col ]]; then

                                    to_delete=$pos_i 

                                    break
                                    fi
                            done

                            if [[ $to_delete -eq -1 ]]; then
                                
                                echo "DIDN'T FIND WHAT TO DELETE"
                                exit
                            fi

                            for (( pos_i = to_delete; pos_i < number_of_carts - 1; ++pos_i )); do
                                cart_pos_row[$pos_i]=${cart_pos_row[$(( pos_i + 1 ))]} 
                                cart_pos_col[$pos_i]=${cart_pos_col[$(( pos_i + 1 ))]} 
                            done
                            unset "cart_pos_row[$(( number_of_carts - 1))]"
                            unset "cart_pos_col[$(( number_of_carts - 1))]"
                            ((number_of_carts-=2))
                            echo "POSLENGTH NOW $pos_length"
                            if [[ $to_delete -le $i ]]; then
                                ((--i))
                            fi



                            track_map[$row,$col]="$underlying_track"
                            next_underlying_track=($next_underlying_track)
                            next_underlying_track=${next_underlying_track[2]}
                            track_map[$next_row,$next_col]="$next_underlying_track"


                            echo "${cart_pos_row[@]}"
                        else
                            cart_pos_row[$i]=$next_row
                            cart_pos_col[$i]=$next_col
                            track_map[$row,$col]="$underlying_track"
                            track_map[$next_row,$next_col]="$next_dir $next_intersection_dir $next_underlying_track $tick"
                        fi

                    fi

                fi

            fi
            
        
    done

    sort_cart_pos

    if [[ $number_of_carts -eq 1 ]]; then
        echo "answer: ${cart_pos_col[0]},${cart_pos_row[0]}"
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
