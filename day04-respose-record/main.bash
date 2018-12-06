#!/bin/bash

# PART 1

# Sed command below deserves some explanation:
# It takes the whole input and transforms it into a space separated list (to be 
#   read by Bash as an array). The output from sed is piped to sort (the default 
#   behavior of sort turns out to be good enough)
# Here is the result of parsing the example input in this way:
: '
11 01 00 00 10
11 01 00 05 falls
11 01 00 25 wakes
11 01 00 30 falls
11 01 00 55 wakes
11 01 23 58 99
11 02 00 40 falls
11 02 00 50 wakes
11 03 00 05 10
11 03 00 24 falls
11 03 00 29 wakes
11 04 00 02 99
11 04 00 36 falls
11 04 00 46 wakes
11 05 00 03 99
11 05 00 45 falls
11 05 00 55 wakes
'

input=$(</dev/stdin)
ordererd_and_parsed_input=$(echo "$input" | sed 's/^\[1518-\([[:digit:]][[:digit:]]\)-\([[:digit:]][[:digit:]]\)\s\([[:digit:]][[:digit:]]\):\([[:digit:]][[:digit:]]\)\]\s.*#\([[:digit:]]*\).*/\1 \2 \3 \4 \5/;s/^\[1518-\([[:digit:]][[:digit:]]\)-\([[:digit:]][[:digit:]]\)\s\([[:digit:]][[:digit:]]\):\([[:digit:]][[:digit:]]\)\]\s\(\w*\b\).*/\1 \2 \3 \4 \5/' | sort)

declare -A guard_map
current_guard=-1
asleep_minute=-1
guard_ids=()
while read -r line; do

    entry_array=($line)

    # action is the field that is either "wakes" "falls" or a guard id
    action="${entry_array[4]}"

    case $action in
        wakes)

            # use asleep time to calc diff
            # Bash parameter expanion is used to remove potential leading 0
            awake_minute=${entry_array[3]##0}
            diff=$(( awake_minute - asleep_minute ))
            guard_map[$current_guard,total]=$(( ${guard_map[$current_guard,total]} + diff ))

            # update minute map for guard
            for (( i=asleep_minute; i<awake_minute; i++ )); do
                ((guard_map[$current_guard,$i]++))    
            done
            ;;
        falls)
            # store asleep time
            # Bash parameter expanion is used to remove potential leading 0
            asleep_minute=${entry_array[3]##0}
            ;;
        *)
            current_guard=$action

            # if not seen before, initialize to zero and add guard id to array
            if [[ -z ${guard_map[$current_guard,total]+_} ]]; then
                guard_map[$current_guard,total]=0
                guard_ids+=($current_guard)
            fi
            ;;
    esac

done < <(echo "$ordererd_and_parsed_input")

max_id=-1
max_val=-1
for guard_id in "${guard_ids[@]}"; do
    if [[ ${guard_map[$guard_id,total]} -gt max_val ]]; then
        max_id=$guard_id
        max_val="${guard_map[$guard_id,total]}"
    fi
done

# store id of sleepiest guard (first half of part 1)
sleepiest_guard_id=$max_id

# find when guard was most asleep
declare -A minute_map
skipping=true
asleep_minute=-1
while read -r line; do

    entry_array=($line)
    action="${entry_array[4]}"

    if [[ $action -eq $sleepiest_guard_id ]]; then
        skipping=false
    elif [[ $skipping = false ]] && [[ $action == wakes ]]; then
        awake_minute=${entry_array[3]##0}

        # for each minute increase sleep count
        for (( i=asleep_minute; i<awake_minute; i++)); do
            minute_map[$i]=$(( ${minute_map[$i]} + 1 ))
        done

    elif [[ $skipping = false ]] && [[ $action == falls ]]; then
        asleep_minute=${entry_array[3]##0}
    else
        skipping=true
    fi

done < <(echo "$ordererd_and_parsed_input")



max_id=-1
max_val=-1
for minute_id in "${!minute_map[@]}"; do
    if [[ ${minute_map[$minute_id]} -gt max_val ]]; then
        max_id=$minute_id
        max_val="${minute_map[$minute_id]}"
    fi
done

echo "$(( sleepiest_guard_id * max_id ))"


# PART 2

max_id=-1
max_val=-1
max_minute=-1
for guard_id in "${guard_ids[@]}"; do
    
    inner_max_minute_id=-1
    inner_max_minute_val=-1
    for (( i=0; i<60; i++ )); do
        if [[ ${guard_map[$guard_id,$i]} -gt inner_max_minute_val ]]; then
            inner_max_minute_id=$i
            inner_max_minute_val=${guard_map[$guard_id,$i]}
        fi
    done

    if [[ $inner_max_minute_val -gt $max_val ]]; then
        max_id=$guard_id
        max_minute=$inner_max_minute_id
        max_val=$inner_max_minute_val
    fi

done

echo "$(( max_id * max_minute ))"

