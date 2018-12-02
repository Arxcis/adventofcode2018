package main

import (
	"fmt"
	"os"
)

func main(){
	//
	// Read args values into integer array
	//
	if len(os.Args) < 2 {
		panic("Missing input")
	}
	args := os.Args[1:]

	//PART 1
	//Store total occurrences of each letter
	totalTwo := 0
	totalThree := 0

	//Loop through all arguments
	for _, line := range args {

		//Were there two or three occurrences of a letter in this line
		two := false
		three := false

		//Create a map that maps each letter to a count of how many times it occurs
		charNr := make(map[string]int)

		//Loop over the line, and for each letter count up the occurrence for that letter
		for _, char := range line {
			charNr[string(char)]++
		}

		//Loop over all letters, count occurrences
		for i := range charNr {
			//Extract amount of occurrences
			nr := charNr[i]

			//If that is 2 or 3, set that to true
			if nr == 2 {
				two = true
			} else if nr == 3 {
				three = true
			}
		}

		//If there were two or three occurrences count up that total
		if two {
			totalTwo++
		}
		if three {
			totalThree++
		}
	}
	fmt.Println(totalTwo * totalThree)

	//PART 2
	//Create map with ID and a bool for if one character is different
	IDs := make(map[string]bool)

	//Create output string
	var output string

	//Loop while not at end of file
	for _, line := range args {

		//Loop through all IDs
		for id := range IDs {
			//Clear output string
			output = ""

			//For each id, loop through the current line
			for i := range line {
				//Compare the same index in id with line
				if id[i] == line[i] {
					//If they are the same, add to output
					output = fmt.Sprintf("%s%s", output, string(id[i]))
				} else {
					//If the letters are not the same check if this is the first time
					if IDs[id] {
						//If the letters have been the same before, set id to false and break to next id
						IDs[id] = false
						break
					} else {
						//If this is the first time, set id to true
						IDs[id] = true
					}
				}
			}
			//If, after comparing the new line with one from IDs, there was exactly one letter difference, we found it
			if IDs[id] {
				fmt.Println(output)
				return
			}
		}
		//After comparing line with all IDs, add this line to IDs
		IDs[line] = false
	}
}
