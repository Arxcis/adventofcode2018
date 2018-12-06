# Welcome to Advent of code 2018 - The many languages challange!

Link: https://adventofcode.com/2018

In this repo we try to solve the daily tasks in as many languages as possible. Pick a language and day which does not have a solution yet and solve it.

### Travis CI

[![Build Status](https://travis-ci.org/Arxcis/adventofcode2018.svg?branch=master)](https://travis-ci.org/Arxcis/adventofcode2018) (Click for details)

### Solution matrix

 | Language | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 |
 |----------|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
 | Go   | x  | x  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
 | C++      | x  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
 | Bash     | x  | x  | x  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
 | Python   |    | x  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
 | Rust     | x  |  x |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
 | Nodejs   |    |    | x  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |

### General
* There are no deadlines (You don't have to submit day01 on 01. desember 2018)
* You may look at other's solutions, or you can do it on your own. Pick your challange.

### Contributing
* To contribute make a pull request with your solution.
* Name your pull-request like this example 'day03-golang'
* Fork repo or ask to join as contributor
* Every solution-file is named 'main' (e.g main.py, main.go, main.ru, main.js, main.cs, ....)

### Input
* Each program should expect the input from `stdin`
* Every folder contains a `input`-file with testdata you can use.
```
$ cat day01/input | day01/main
```

### Output

Each program's output(stdout) is expected to match the `output`-file of each folder:
```
$ cat day01/input | day01/main
408
55250
```
.. matches `day01/output`
```
408
55250
```
* Note: Everyone receives unique input-data on adventofcode.com. The correct answer in this repo will not be the correct answer on your adventofcode.com user. Use your own input-data to score points there.

### Testing

For all available test commands see `package.json`

**Install node and do npm install**

Get the latest node-version using nvm (https://github.com/creationix/nvm)
```
$ nvm install node

$ node -v
v11.3.0

$ npm -v
6.4.1

$npm install
.... installing packages
```


**Generate tests for all solutions**
```
$ npm run generate

Generated day01-chronal-calibration/test.js
Generated day02-inventory-management-system/test.js
Generated day03-no-matter-how-you-slice-it/test.js
Generated day04-respose-record/test.js
Generated day05-alchemical-reduction/test.js
```
Re-run everytime you add a new file

**Test all programs**
```
$ npm run all

  ✖ No tests found in day03-no-matter-how-you-slice-it/test.js
  ✔ day01-chronal-calibration › test › main.go (574ms)
  ✔ day02-inventory-management-system › test › main.go (593ms)
  ✔ day02-inventory-management-system › test › main.py (663ms)
  ✔ day01-chronal-calibration › test › main.rs (1.4s)
  ✔ day01-chronal-calibration › test › main.cpp (1.7s)

  5 tests passed

```

**Test specific language**
```
 npm run go

  ✔ day01-chronal-calibration › test › main.go (381ms)
  ✔ day02-inventory-management-system › test › main.go (418ms)

  2 tests passed

```

**Test specific day**
```
$ npm run all day01-chronal-calibration/

  ✔ main.go (457ms)
  ✔ main.rs (1.4s)
  ✔ main.cpp (1.8s)

  3 tests passed

```

**Test specific day AND specific language**
```
$ npm run py day02-inventory-management-system/

  ✔ main.py (207ms)

  1 test passed

```
