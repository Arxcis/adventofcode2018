#!/usr/local/bin/python3

import fileinput

def main():
    frequencyChanges = []
    for line in fileinput.input():
        frequencyChanges.append(line.replace("\n", ""))

    #
    # Part 1
    #
    currentFrequency = 0
    for change in frequencyChanges:
        currentFrequency += int(change)
    
    print(currentFrequency)

    #
    # Part 2
    #
    currentFrequency = 0
    currentFrequencyVisited = {}


if __name__ == "__main__":
    main()