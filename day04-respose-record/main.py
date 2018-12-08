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

class MinuteRange:
    def __init__(self, start):
        self.start = start;
        self.stop = None

class Shift:
    
    def __init__(self, guard_id):
        self.guard_id = guard_id
        self.minute_ranges = []
        self.temp = None

    def falls_asleep(self, start_minute):
        self.temp = MinuteRange(start_minute)

    def wakes_up(self, stop_minute):
        self.temp.stop = stop_minute
        self.minute_ranges.append(self.temp)
        self.temp = None

class MinuteCounter:
    
    def __init__(self):
        self.minutes = [0 for i in range(0,59)]

    def count(self, minute_ranges):
        for minute_range in minute_ranges:
            for i in range(minute_range.start, minute_range.stop):
                self.minutes[i] += 1            

    def sum(self):
        return sum(self.minutes)

    def __str__(self):
        return f"{''.join((str(counter) for counter in self.minutes))}: {self.sum()}"

def main():

    #
    # Part 1
    # ..parse each line into an Entry struct
    #
    entries = [Entry(line) for line in fileinput.input()]

    #
    # ..sort by date ascending
    #
    entries.sort(key=lambda entry: entry.timestamp)


    #
    # ..parse each shift into Shift struct
    #
    minute_counters = {}
    shifts = []
    shift = None
    regex_guard = re.compile(r'#(\d+) begins shift')    
   
    for entry in entries:
        if entry.command == 'Guard':
            if shift is not None:
                shifts.append(shift)
                shift = None

            [guard_id] = re.search(regex_guard, entry.rest).groups()
            shift = Shift(guard_id)
            minute_counters[guard_id] = None

        elif entry.command == 'wakes':
            shift.wakes_up(entry.minute)

        elif entry.command == 'falls':
            shift.falls_asleep(entry.minute)

    #
    # ...make one minute counter for each guard
    #
    for guard_id in minute_counters.keys():
        minute_counters[guard_id] = MinuteCounter()

    #
    # ..count minutes of each guard
    #
    for shift in shifts:
        minute_counters[shift.guard_id].count(shift.minute_ranges)

    #
    # ...find the guard who sleeps most minutes
    #
    sums = zip(
        [counter.sum() for counter in minute_counters.values()], 
        minute_counters.values())

    guard_who_sleeps_the_most = max([s for s in sums])

    #
    # ...find the minute he sleeps the most
    #
    minutes = enumerate(guard_who_sleeps_the_most[1].minutes)
    minute_he_most_often_sleeps = max([(value, index) for index, value in minutes])
    print(guard_who_sleeps_the_most[0] * minute_he_most_often_sleeps[1])

if __name__ == "__main__":
    main()
