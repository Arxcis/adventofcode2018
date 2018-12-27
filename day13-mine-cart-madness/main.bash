#!/bin/bash

###############################################################################
### CART DATASTRUCTURE
###
### The four cart arrays are closely related. Position i in each array gives 
### information about a particular cart. cart_pos_row[i] holds the row of cart
### i, cart_underlying_track[i] holds the underlying track of cart i, and so 
### on. When sorting all of the arrays are treated as one during swaps.
###############################################################################


number_of_carts=0

# holds row position of carts
cart_pos_row=()                         

# holds col position of carts
cart_pos_col=()                         

# holds next direction to go in an intersection for carts
cart_next_intersection_direction=()     

# holds the piece of track that is under the carts. (The track_map stores the 
# <,>,^,v of each cart, so need to remember what is under every cart for when 
# it moves)
cart_underlying_track=()

# selection sort of the arrays based on position
# sorts by row and col (so that looping through the arrays read from left 
# to right, top to bottom)
function sort_cart_arrays() {

    local i
    local j

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

        local tmp=${cart_next_intersection_direction[$i]}
        cart_next_intersection_direction[$i]=${cart_next_intersection_direction[$min_index]}
        cart_next_intersection_direction[$min_index]=$tmp

        local tmp=${cart_underlying_track[$i]}
        cart_underlying_track[$i]=${cart_underlying_track[$min_index]}
        cart_underlying_track[$min_index]=$tmp

    done

}

# delete a cart from the arrays given it's index
function delete_cart() {

    local to_delete="$1"
    local i
    
    for (( i = to_delete; i < number_of_carts - 1; ++i )); do
        cart_pos_row[$i]=${cart_pos_row[$(( i + 1 ))]} 
        cart_pos_col[$i]=${cart_pos_col[$(( i + 1 ))]} 
        cart_next_intersection_direction[$i]=${cart_next_intersection_direction[$(( i + 1 ))]} 
        cart_underlying_track[$i]=${cart_underlying_track[$(( i + 1 ))]} 
    done
    unset "cart_pos_row[$(( number_of_carts - 1))]"
    unset "cart_pos_col[$(( number_of_carts - 1))]"
    unset "cart_next_intersection_direction[$(( number_of_carts - 1))]"
    unset "cart_underlying_track[$(( number_of_carts - 1))]"
    ((--number_of_carts))
}

###############################################################################
### PARSE INPUT
###############################################################################

input="$(</dev/stdin)"

# track map is used as a two-dimentional array, where track_map[2,3] holds the 
# piece of track at row 2 and column 3 for. ex. Coordinates that hold no track 
# (" " in input) are not inserted
declare -A track_map

# IFS= to preserve leading spaces
row=0
while IFS= read -r line; do

    line_length="${#line}"

    for (( col = 0; col < line_length; ++col )); do
        current_xy_of_input="${line:$col:1}"

        case "$current_xy_of_input" in
            " ")
                # ignore
                ;;

            \>|\<|^|v)

                ((number_of_carts++))

                # initial input is missing underlying track information, but it can 
                # be inferred from the direction of the carts
                underlying_track="-"
                if [[ $current_xy_of_input =~ [v|^] ]]; then
                    underlying_track="|"
                fi

                cart_pos_row+=($row)
                cart_pos_col+=($col)
                cart_next_intersection_direction+=(0)
                cart_underlying_track+=($underlying_track)

                track_map[$row,$col]="$current_xy_of_input"

                ;;
                
            +|\\|/)
                track_map[$row,$col]="$current_xy_of_input"
                ;;
        esac
        
    done

    ((row++))

done < <(echo "$input")

###############################################################################
### SOLVE PART 1 AND 2
###
### Advance all carts like explained in task while keeping track of first 
### collision and last remaining cart
###
### NOTE that all of the movement code could probably (definately) be made alot 
### cleaner. Currently spaghetti-code
###############################################################################

part_1_solution=""
part_2_solution=""

# used for part 1
seen_first_collision=false

while [[ $number_of_carts -gt 1 ]]; do

    # for every cart (note that the number of carts and even i can be changed 
    # during the loop because of collisions)
    for (( i = 0; i < number_of_carts; ++i )); do

        # fetch information about cart i
        row=${cart_pos_row[$i]}
        col=${cart_pos_col[$i]}
        dir="${track_map[$row,$col]}"
        intersection_dir="${cart_next_intersection_direction[$i]}"
        underlying_track="${cart_underlying_track[$i]}"

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
        # NOTE that could be a cart !
        track_ahead="${track_map[$next_row,$next_col]}"

        # look ahead 
        next_dir=$dir
        next_intersection_dir=$intersection_dir
        collision_found=false
        case $track_ahead in
            -|\|)
                # do nothing
                ;;
            /)
                # turn cart based on where it approached the turn from
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
                # turn cart based on where it approached the turn from
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

                # have reached an intersection, turn based on what the next 
                # intersection turn for the cart is. 0 means left, 1 means 
                # straight, and 2 means right
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

                # update next_intersection_dir. cart should turn left, then straight, 
                # then right, then left, and so on
                ((next_intersection_dir++))
                if [[ $next_intersection_dir -gt 2 ]]; then
                    next_intersection_dir=0
                fi
                ;;
                \<|\>|^|v)
                    # we're about to move into a cart. collision!
                    collision_found=true
                    ;;
        esac

        if $collision_found; then

            # if this is the first collision we've seen -> answer to part 1
            if ! $seen_first_collision; then
                part_1_solution="$next_col,$next_row"
                seen_first_collision=true 
            fi

            # remove current cart
            delete_cart $i
            ((--i))

            # find index of cart collided with
            to_delete=-1
            for (( pos_i = 0; pos_i < number_of_carts; ++pos_i )); do
                if [[ ${cart_pos_row[$pos_i]} -eq $next_row ]] &&
                   [[ ${cart_pos_col[$pos_i]} -eq $next_col ]]; then

                    to_delete=$pos_i 

                    break
                    fi
            done

            # if not found, error out (shouldn't happen..)
            if [[ $to_delete -eq -1 ]]; then
                echo "DIDN'T FIND WHAT TO DELETE"
                exit
            fi

            # remove colliding carts from track_map
            track_map[$row,$col]="$underlying_track"
            track_map[$next_row,$next_col]="${cart_underlying_track[$to_delete]}"
            
            # remove cart current cart collided with
            delete_cart $to_delete

            # only decrease i if was less than or equal to current cart
            if [[ $to_delete -le $i ]]; then
                ((--i))
            fi

        else # (if no collision found, advance cart)

            # update cart arrays
            cart_pos_row[$i]="$next_row"
            cart_pos_col[$i]="$next_col"
            cart_next_intersection_direction[$i]="$next_intersection_dir"
            cart_underlying_track[$i]="$track_ahead"

            # update track_map
            track_map[$row,$col]="$underlying_track"
            track_map[$next_row,$next_col]="$next_dir"
        fi


    done

    # cart arrays have been updated. sort so that we read from top-left to bottom-right 
    # during next loop
    sort_cart_arrays

    # if number of carts is 1 we've reached solution for part 2
    if [[ $number_of_carts -eq 1 ]]; then
        part_2_solution="${cart_pos_col[0]},${cart_pos_row[0]}"
    fi

done

echo "$part_1_solution"
echo "$part_2_solution"
