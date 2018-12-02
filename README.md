# Welcome to Advent of code 2018 - The many languages challange!

Link: https://adventofcode.com/2018

In this repo we try to solve the daily tasks in as many languages as possible. Pick a language and day which does not have a solution yet and solve it.


### Solution matrix

[![Build Status](https://travis-ci.org/Arxcis/adventofcode2018.svg?branch=master)](https://travis-ci.org/Arxcis/adventofcode2018)

 | Language   | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 |
 |------------|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
 | Golang     | x  | x  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
 | C++        | x  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
 | Bash       | x  | x  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
 | Python3    |    | x  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |


### General
* There are no deadlines (You don't have to submit day01 on 01. desember 2018)
* You may look at other's solutions, or you can do it on your own. Pick your challange.

### Contributing
* To contribute make a pull request with your solution.
* Name your pull-request like this example 'day03-golang'
* Fork repo or ask to join as contributor
* Every solution-file is named 'main' (e.g main.py, main.go, main.ru, main.js, main.cs, ....)

### Input
* Each program should expect the input as a list of command-line arguments:
* Every folder contains a `input`-file with testdata you can use.
```
$ ./day01/main $(cat day01/input)
```
...expands to
```
$ ./day01/main +10 -3 -17 +4 +23 +16 -7 -30 +29 -19 +18 -3 ...
```

### Output

Each program's output(stdout) is expected to match the `output`-file of each folder:
```
$ day01/main $(cat day01/input)
408
55250
```
.. matches `day01/output`
```
408
55250
```
* Note: Everyone receives unique input-data on adventofcode.com. The correct answer in this repo will not be the correct answer on your adventofcode.com user. Use your own input-data to score points there.
