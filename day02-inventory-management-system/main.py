#!/usr/local/bin/python3

import sys
import fileinput

def main():
    boxIDList = []
    for line in fileinput.input():
        boxIDList.append(line.replace("\n", ""))

    def part1(boxIDList):

        TWICE = 2
        THRICE = 3
        twiceCount = 0
        thriceCount = 0

        for ID in boxIDList:
            letterCounters = makeLetterCounters()
            for letter in ID:
                letterCounters[letter] += 1

            twiceCount += atleastOneLetterOccursExactly(TWICE, letterCounters)
            thriceCount += atleastOneLetterOccursExactly(THRICE, letterCounters)

        return twiceCount * thriceCount

    def part2(boxIDList):

        for idA in boxIDList:
            for idB in boxIDList:

                if allButOneLetterEqual(idA, idB):
                    equalString = ""
                    for letterA, letterB in zip(idA, idB):
                        if letterA == letterB:
                            equalString += letterA

                    return equalString

    print(part1(boxIDList))
    print(part2(boxIDList))

def allButOneLetterEqual(idA, idB):
    ID_LENGTH = 26
    
    equalCount = 0
    for letterA, letterB in zip(idA, idB):
        if letterA == letterB:
            equalCount += 1

    return equalCount == ID_LENGTH-1

def makeLetterCounters():
    alphabet = 'abcdefghijklmnopqrstuvwxyz'
    letterCounters = {}
    for letter in alphabet:
        letterCounters[letter] = 0

    return letterCounters

def atleastOneLetterOccursExactly(n, letterCounters):
    for letter, count in letterCounters.items():
        if count == n:
            return 1
    return 0

if __name__ == "__main__":
    main()