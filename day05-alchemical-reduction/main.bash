#!/bin/bash

# Inspiration for $sed_pairs: https://unix.stackexchange.com/a/340080
# NOTE: PART 2 could probably be sped up a whole lot by figuring out a way to 
#       call sed only once. Give it one line per removed character for example?

# PART 1

input=$(</dev/stdin)
sed_pairs=$(echo {a..z} | sed 's/\(\b\w\b\)\s*/\1\u\1|\u\1\1|/g;s/|$//')
part_1_solution=$(echo "$input" | sed -E ":a s/$sed_pairs//g;ta" | tr -d '\n' | wc -c)
echo $part_1_solution

# PART 2

min_char=ø
min_length=$part_1_solution
for char in {a..z}; do
    completely_reacted=$(echo $input | sed "s/$char//Ig")
    length=$(echo "$completely_reacted" | sed -E ":a s/$sed_pairs//g;ta" | tr -d '\n' | wc -c)
    if [[ $length -lt $min_length ]]; then
        min_length=$length
        min_char=$char
    fi
done

echo $min_length
