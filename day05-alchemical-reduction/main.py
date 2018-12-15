
import fileinput
import time
import sys

alphabet = "abcdefghijklmnopqrstuvwxyz"
lower_UPPER_pairs = [(f"{c.lower()}{c.upper()}", 
        f"{c.upper()}{c.lower()}") for c in alphabet]


def main():
    global alphabet
    initial_polymer = [line for line in fileinput.input()][0]
    
    #
    # Part 1
    #
    print(fully_reacted_length(initial_polymer))

    #
    # Part 2
    #
    min_len = 10**100 # gogool
    for c in alphabet:
        new_len = fully_reacted_length(
            initial_polymer
            .replace(c.lower(), "")
            .replace(c.upper(), ""))

        print(c, ":", new_len)
        if new_len < min_len:
            min_len = new_len

    print(min_len)


def fully_reacted_length(polymer):
    global alphabet, lower_UPPER_pairs

    oldlen = 0
    newlen = len(polymer)

    while oldlen != newlen:
        for lowerUPPER, UPPERlower in lower_UPPER_pairs:
            polymer = polymer.replace(lowerUPPER, "")
            polymer = polymer.replace(UPPERlower, "")

        oldlen = newlen
        newlen = len(polymer)

    return len(polymer)

if __name__ == "__main__":
    main()
