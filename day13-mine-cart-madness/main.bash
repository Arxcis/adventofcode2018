#!/bin/bash

function sort_pos() {

    local i
    local j

    # sort by row
    local pos_length="${#pos_row[@]}"
    for (( i = 0; i < pos_length; ++i )); do
        local min_index=$i
        for (( j = i + 1; j < pos_length; ++j )); do
            if [[ ${pos_row[$j]} -le ${pos_row[$min_index]} ]] &&
               [[ ${pos_col[$j]} -lt ${pos_col[$min_index]} ]]; then
                min_index=$j
            fi
        done

        local tmp=${pos_row[$i]}
        pos_row[$i]=${pos_row[$min_index]}
        pos_row[$min_index]=$tmp

        local tmp=${pos_col[$i]}
        pos_col[$i]=${pos_col[$min_index]}
        pos_col[$min_index]=$tmp

    done

}


input="$(</dev/stdin)"

declare -A track_map

next_cart_number_to_assign=0

number_of_carts=0

pos_row=()
pos_col=()

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

                pos_row+=($row)
                pos_col+=($col)

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

echo "${pos_row[@]}"
echo "${pos_col[@]}"

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

    pos_length=${#pos_row[@]}
    for (( i = 0; i < pos_length; ++i )); do

            row=${pos_row[$i]}
            col=${pos_col[$i]}
            echo "$row,$col"

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

                            for (( pos_i = i; pos_i < pos_length - 1; ++pos_i )); do
                                pos_row[$pos_i]=${pos_row[$(( pos_i + 1 ))]} 
                                pos_col[$pos_i]=${pos_col[$(( pos_i + 1 ))]} 
                            done
                            unset "pos_row[$(( pos_length - 1))]"
                            unset "pos_col[$(( pos_length - 1))]"
                            pos_length="${#pos_row[@]}"
                            echo "POSLENGTH NOW $pos_length"
                            ((--i))

                            to_delete=-1
                            for (( pos_i = 0; pos_i < pos_length; ++pos_i )); do
                                if [[ ${pos_row[$pos_i]} -eq $next_row ]] &&
                                   [[ ${pos_col[$pos_i]} -eq $next_col ]]; then

                                    to_delete=$pos_i 

                                    break
                                    fi
                            done

                            if [[ $to_delete -eq -1 ]]; then
                                
                                echo "DIDN'T FIND WHAT TO DELETE"
                                exit
                            fi

                            for (( pos_i = to_delete; pos_i < pos_length - 1; ++pos_i )); do
                                pos_row[$pos_i]=${pos_row[$(( pos_i + 1 ))]} 
                                pos_col[$pos_i]=${pos_col[$(( pos_i + 1 ))]} 
                            done
                            unset "pos_row[$(( pos_length - 1))]"
                            unset "pos_col[$(( pos_length - 1))]"
                            pos_length="${#pos_row[@]}"
                            echo "POSLENGTH NOW $pos_length"
                            if [[ $to_delete -lt $i ]]; then
                                ((--i))
                            fi



                            track_map[$row,$col]="$underlying_track"
                            next_underlying_track=($next_underlying_track)
                            next_underlying_track=${next_underlying_track[2]}
                            track_map[$next_row,$next_col]="$next_underlying_track"
                        else
                            pos_row[$i]=$next_row
                            pos_col[$i]=$next_col
                            track_map[$row,$col]="$underlying_track"
                            track_map[$next_row,$next_col]="$next_dir $next_intersection_dir $next_underlying_track $tick"
                        fi

                        


                        #echo "NEXT for cart! $next_row,$next_col $next_dir,$next_intersection_dir $next_underlying_track $tick"


                    fi

                fi

            fi
            
        
    done

    sort_pos

    if [[ $number_of_carts -eq 1 ]]; then
        for xy in "${!track_map[@]}"; do
            if [[ ${track_map[$xy]} =~ [\<\>^v] ]]; then
                echo "answer: ${xy#*,},${xy%,*}"
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
