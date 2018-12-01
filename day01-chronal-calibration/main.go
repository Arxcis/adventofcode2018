package main

import (
    "bufio"
    "os"
    "strconv"
    "fmt"
)

func main() {
    //
    // Read file values into array
    //
    file, err := os.Open("puzzle.input")
    check(err)
    
    frequencyChanges := make([]int, 0)
    r := bufio.NewReader(file)
    for lineb, stop := r.ReadBytes('\n'); stop == nil; lineb, stop = r.ReadBytes('\n') { 
        line := string(lineb[:len(lineb)-1])
        
        change, _ := strconv.ParseInt(line, 10, 32)
        check(err)

        frequencyChanges = append(frequencyChanges, int(change))
    }

    //
    // Puzzle 1
    //
    {
        currentFrequency := 0
        for _, change := range frequencyChanges {
            fmt.Println(change)
            currentFrequency += change
        }
        fmt.Println("day01-cronal-calibration-puzzle1:", currentFrequency)
    }
    //
    // Puzzle 2
    //
    {
        currentFrequency := 0
        currentFrequencyVisited := make(map[int]int)
        firstDuplicate := 0
        firstDuplicateFound := false

        for !firstDuplicateFound {
            for _, change := range frequencyChanges {
                if duplicate, ok := currentFrequencyVisited[currentFrequency]; ok {
                    firstDuplicate = duplicate
                    firstDuplicateFound = true;
                    break;
                } else {
                    currentFrequencyVisited[currentFrequency] = currentFrequency
                }
                currentFrequency += change
            }
        }
        fmt.Println("day01-cronal-calibration-puzzle2:", firstDuplicate)
    }
}

func check(e error) {
    if e != nil {
        panic(e)
    }
}
