import sys
import fileinput
import re

# Commands
GUARD = 'Guard'
WAKES = 'wakes'
FALLS = 'falls'
REGEX_LINE = r'\[(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d)\] (.{5}) (.*)'
REGEX_REST = r'.* .* .*'
def main():
    lines = []
    for line in fileinput.input():

        m = re.search(REGEX_LINE, line)
        year, month, day, hour, minute, command, rest = m.groups()
        print(year, month, day, hour, minute, command, rest)

        if command == GUARD:
            print(GUARD)
        elif command == WAKES:
            print(WAKES)
        elif command == FALLS:
            print(FALLS)

if __name__ == "__main__":
    main()
