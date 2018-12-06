#!/bin/bash

# sed command that outputs this (should be easier to work with. can remove the --)
: '
04 29 00 03 -- 101
10 21 00 55 -- falls
08 31 23 59 -- 101
10 05 00 04 -- 691
03 05 00 19 -- falls
06 04 23 46 -- 827
06 13 23 47 -- 283
09 30 00 48 -- wakes
05 26 00 54 -- wakes
08 11 00 47 -- falls
03 13 00 54 -- wakes
06 09 00 45 -- wakes
05 31 00 53 -- wakes
10 13 00 51 -- falls
07 22 00 18 -- wakes
'
# `sed 's/^\[1518-\([[:digit:]][[:digit:]]\)-\([[:digit:]][[:digit:]]\)\s\([[:digit:]][[:digit:]]\):\([[:digit:]][[:digit:]]\)\]\s.*#\([[:digit:]]*\).*/\1 \2 \3 \4 -- \5/;s/^\[1518-\([[:digit:]][[:digit:]]\)-\([[:digit:]][[:digit:]]\)\s\([[:digit:]][[:digit:]]\):\([[:digit:]][[:digit:]]\)\]\s\(\w*\b\).*/\1 \2 \3 \4 -- \5/'`

input=$(</dev/stdin)
ordererd_and_parsed_input=$(echo "$input" | sed 's/^\[1518-\([[:digit:]][[:digit:]]\)-\([[:digit:]][[:digit:]]\)\s\([[:digit:]][[:digit:]]\):\([[:digit:]][[:digit:]]\)\]\s.*#\([[:digit:]]*\).*/\1 \2 \3 \4 \5/;s/^\[1518-\([[:digit:]][[:digit:]]\)-\([[:digit:]][[:digit:]]\)\s\([[:digit:]][[:digit:]]\):\([[:digit:]][[:digit:]]\)\]\s\(\w*\b\).*/\1 \2 \3 \4 \5/' | sort)

declare -A guard_map
current_guard=-1
asleep_minute=-1
while read -r line; do

    entry_array=($line)
    action="${entry_array[4]}"

    case $action in
        wakes)

            # use asleep time to calc diff
            awake_minute=${entry_array[3]##0}
            diff=$(( awake_minute - asleep_minute ))
            guard_map[$current_guard]=$(( ${guard_map[$current_guard]} + diff ))

            echo "GUARD_ID($current_guard) $awake_minute,$asleep_minute,$diff -> new total ${guard_map[$current_guard]} - ${#guard_map[@]}"

            ;;
        falls)
            asleep_minute=${entry_array[3]##0}
            ;;
        *)
            current_guard=$action

            # if not seen before, initialize to zero
            if [[ -z ${guard_map[$current_guard]+_} ]]; then
                guard_map[$current_guard]=0
            fi

            ;;
    esac

done < <(echo "$ordererd_and_parsed_input")


# find guard with max sleeptime
max_id=-1
max_val=-1
for guard_id in "${!guard_map[@]}"; do
    echo "$guard_id ${guard_map[$guard_id]}"
    if [[ ${guard_map[$guard_id]} -gt max_val ]]; then
        max_id=$guard_id
        max_val="${guard_map[$guard_id]}"
        echo "found new max! id: $max_id with $max_val"
    fi
done

part_1_guard=$max_id

# DEBUG
echo "$ordererd_and_parsed_input"

# find when guard was most asleep
declare -A minute_map
skipping=true
asleep_minute=-1
while read -r line; do

    entry_array=($line)
    action="${entry_array[4]}"

    if [[ $action -eq $part_1_guard ]]; then
        skipping=false
    elif [[ $skipping = false ]] && [[ $action == wakes ]]; then
        echo "$action - wakes"
        awake_minute=${entry_array[3]##0}

        # for each minute increase sleep count
        for (( i=asleep_minute; i<awake_minute; i++)); do
            minute_map[$i]=$(( ${minute_map[$i]} + 1 ))
        done

    elif [[ $skipping = false ]] && [[ $action == falls ]]; then
        echo "$action - falls"
        asleep_minute=${entry_array[3]##0}
    else
        skipping=true
    fi

done < <(echo "$ordererd_and_parsed_input")



max_id=-1
max_val=-1
for minute_id in "${!minute_map[@]}"; do
    echo "$minute_id ${minute_map[$minute_id]}"
    if [[ ${minute_map[$minute_id]} -gt max_val ]]; then
        max_id=$minute_id
        max_val="${minute_map[$minute_id]}"
        echo "found new max! id: $max_id with $max_val"
    fi
done

echo "answer: $part_1_guard $max_id"
echo "$(( part_1_guard * max_id ))"
