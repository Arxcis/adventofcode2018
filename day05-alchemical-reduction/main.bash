#!/bin/bash

sed_pairs=$(echo {a..z} | sed 's/\(\b\w\b\)\s*/\1\u\1|\u\1\1|/g;s/|$//')
echo "$(</dev/stdin)" | sed -E ":a s/`echo $sed_pairs`//g;ta" | tr -d '\n' | wc -c
