
import fileinput
import time
import sys
#
# ------------- Part 1 ------------------
#
polymer = f"{[line for line in fileinput.input()][0]}"
alphabet = "abcdefghijklmnopqrstuvwxyz"

oldlen = 0
newlen = len(polymer)

while oldlen != newlen:
    for c in alphabet:
        polymer = polymer.replace(f"{c}{c.upper()}", "")
    for c in alphabet:
        polymer = polymer.replace(f"{c.upper()}{c}", "")

    oldlen = newlen
    newlen = len(polymer)
    print(oldlen, newlen)

print(len(polymer))