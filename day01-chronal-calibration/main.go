package main

import (
    "os"
    "strconv"
    "fmt"
    "bufio"
)

func main() {
    //
    // Read args values into integer array
    //
    args := make([]string, 0)
    s := bufio.NewScanner(os.Stdin)
    for s.Scan() {
        args = append(args, s.Text())
    }

    frequencyChanges := make([]int, len(args))
    for i, changeStr := range args { 
        change, e := strconv.ParseInt(changeStr, 10, 32)
        if e != nil {
            panic(e)
        }
        frequencyChanges[i] = int(change)
    }
    //
    // Part 1
    //
    {
        currentFrequency := 0
        for _, change := range frequencyChanges {
            currentFrequency += change
        }
        fmt.Println(currentFrequency)
    }
    //
    // Part 2
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
        fmt.Println(firstDuplicate)
    }
}

