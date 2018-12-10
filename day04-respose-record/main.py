import sys
import fileinput
import re
import time


class Entry:
    regex_line = re.compile(r'\[(\d\d\d\d-\d\d-\d\d \d\d:(\d\d))\] (.{5}) (.*)')

    def __init__(self, line):
        timestamp, minute, command, rest = re.search(Entry.regex_line, line).groups()
        self.timestamp = time.strptime(timestamp, "%Y-%m-%d %H:%M")
        self.minute = int(minute)
        self.command = command
        self.rest = rest


class Observation:
    def __init__(self, guard_id, begin, end):
        self.guard_id = guard_id
        self.begin = begin
        self.end = end


def main():

    #
    # ------------- Part 1 ------------------
    #
    # ..parse each line into an Entry struct, sort by date ascending
    #
    entries = [Entry(line) for line in fileinput.input()]
    entries.sort(key=lambda entry: entry.timestamp)

    #
    # ..parse each shift into Shift struct + keep track of unique guard ids
    #
    regex_guard = re.compile(r'#(\d+) begins shift')    

    observations = []
    guard_id = None
    begin = None
    end = None
    score = {}

    for entry in entries:
        if entry.command == 'Guard':
            [gid] = re.search(regex_guard, entry.rest).groups()
            guard_id = int(gid)
            score[int(guard_id)] = None

        elif entry.command == 'falls':
            begin = entry.minute

        elif entry.command == 'wakes':
            end = entry.minute
            observations.append(Observation(guard_id, begin, end))


    #
    # ...init score table
    #
    for keys in score.keys():
        score[keys] = [0 for i in range(0,59)]


    #
    # ...count minutes
    #
    for obs in observations:
        for i in range(obs.begin, obs.end):
            score[obs.guard_id][i] += 1

    #
    # ...sum minutes
    #
    sums = {}
    for guard_id, minutes in score.items():
        sums[guard_id] = sum(minutes)

    #
    # ...max minutes for each guard
    #

    #
    # ...find max guard and the minute he sleeps the most
    #
    maxguard = max([z for z in zip(sums.values(), sums.keys())])
    maxminute = max([(val, i) for i, val in enumerate(score[maxguard[1]])])

    guard_id_who_sleeps_the_most = maxguard[1]
    minute_he_sleeps_the_most = maxminute[1]
    
    print(guard_id_who_sleeps_the_most * minute_he_sleeps_the_most)

    #
    # Part 2
    #
    maxminute = max((max(((minute, i, guard_id) 
        for i, minute in enumerate(minutes))) 
            for guard_id, minutes in score.items()))


    print(maxminute[1] * maxminute[2])



if __name__ == "__main__":
    main()
