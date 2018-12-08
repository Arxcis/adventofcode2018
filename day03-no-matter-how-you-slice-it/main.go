package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

//AAndB is part 1 and part 2 of day 3
//nolint: gocyclo
func main() () {
	//All code is for part 1 except for where noted
	const fabricSize int = 1000
	//
	// Read args values into integer array
	//
	args := make([]string, 0)
	s := bufio.NewScanner(os.Stdin)
	for s.Scan() {
		args = append(args, s.Text())
	}

	//Create fabric in memory
	var fabric = make([][]string, fabricSize)
	for i := range fabric {
		fabric[i] = make([]string, fabricSize)
	}
	//Fill fabric with "  .  " to signify blank
	blank := "  .  "
	for y := fabricSize - 1; y >= 0; y-- {
		for x := 0; x < fabricSize; x++ {
			fabric[x][y] = blank
		}
	}

	//Reset overlap
	overlap := 0

	//PART 2: Create map for if each ID has no overlap
	notOverlapMap := make(map[int]bool)
	//

	//Loop while not at end of file
	for _, line := range args {

		//Split line on space, creating 4 parts: #<id>	@	<fromLeft>,<fromTop>:	<width>x<height>
		parts := strings.SplitN(line, " ", 4)

		//Extract id and remove leading # (it is still string)
		textID := parts[0][1:]
		//PART 2: Create numeric value of ID, add it to the map expecting it to be unique
		numID, err := strconv.Atoi(textID)
		if err != nil {
			log.Fatal(err)
		}
		notOverlapMap[numID] = true
		//

		//Reset default fabricID
		fabricID := "  .  "
		//Check digits and make correct input
		if len(textID) == 1 {
			fabricID = strings.Replace(fabricID, ".", textID, 1)
		} else if len(textID) == 2 {
			fabricID = strings.Replace(fabricID, ". ", textID, 1)
		} else if len(textID) == 3 {
			fabricID = strings.Replace(fabricID, " . ", textID, 1)
		} else if len(textID) == 4 {
			fabricID = strings.Replace(fabricID, " .  ", textID, 1)
		} else {
			log.Fatal("textID has either zero or over three digits, textID has: ", len(textID), " digits and is ", len(textID))
		}

		//Extract fromLeft and fromTop
		from := strings.Split(parts[2], ",")
		fromLeft, err := strconv.Atoi(from[0])
		if err != nil {
			log.Fatal(err)
		}
		fromTop, err := strconv.Atoi(strings.TrimSuffix(from[1], ":"))
		if err != nil {
			log.Fatal(err)
		}

		//Extract width and height
		rectangle := strings.Split(parts[3], "x")
		width, err := strconv.Atoi(rectangle[0])
		if err != nil {
			log.Fatal(err)
		}
		height, err := strconv.Atoi(rectangle[1])
		if err != nil {
			log.Fatal(err)
		}

		//Traverse the fabric, if string is blank, insert id
		for j := fromTop; j < fromTop+height; j++ {
			for i := fromLeft; i < fromLeft+width; i++ {
				if fabric[j][i] == blank {
					fabric[j][i] = fabricID
				} else if fabric[j][i] != "  X  " {
					//PART 2: Set both current ID and the ID in the fabric as notOverlap = false
					notOverlapMap[numID] = false
					numFabricID, err := strconv.Atoi(strings.TrimSpace(fabric[j][i]))
					if err != nil {
						log.Panic(err)
					}
					notOverlapMap[numFabricID] = false
					fabric[j][i] = "  X  "
					overlap++
				}else{
						notOverlapMap[numID] = false
				}
			}
		}
	}
	fmt.Println(overlap)

	//PART 2: Find the one ID in the map that is true, that is the notOverlap ID
	for id := range notOverlapMap {
		if notOverlapMap[id] == true {
			fmt.Println(id)
			break
		}
	}
}
