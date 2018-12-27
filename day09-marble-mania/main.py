import fileinput
import re

def main():
    #
    # Part 0 - Parse input
    #
    _input = [line for line in fileinput.input()][0]
    player_count, last_marble = re.search(
        r'([\d]+) players; last marble is worth ([\d]+) points', _input).groups()
    
    player_count = int(player_count)
    last_marble = int(last_marble)

    #
    # Part 1
    #
    print(max_player_score(last_marble, player_count))

    #
    # Part 2
    #
    # Note: Takes too long to complete
    # print(max_player_score(last_marble*100, player_count))


def max_player_score(last_marble, player_count):

    player_score = [0 for i in range(player_count)]   
    current_marble_index = 0
    marbles = [0]

    i = 1
    while i <= last_marble:
        for player in range(player_count): 
            #
            # Exit condition
            #
            if i > last_marble:
                break

            #
            # Special case -> 'i' is multiple of 23
            #   1. Player keeps marble
            #   2. Add marble to player score
            #   3. Remove marble seven steps counter clockwise and also add to player score
            #   4. Set new current marble as the immediate marble clockwise from the remove marble
            #
            elif i % 23 == 0:
                index_seven_steps_counter_clockwise = current_marble_index - 7

                # Wrap around if negative index
                if index_seven_steps_counter_clockwise < 0:
                    index_seven_steps_counter_clockwise = len(marbles) + index_seven_steps_counter_clockwise

                popped_marble = marbles.pop(index_seven_steps_counter_clockwise)
                player_score[player] += i
                player_score[player] += popped_marble

                current_marble_index = index_seven_steps_counter_clockwise

            #
            # Normal case
            #   Player places marble on board
            #
            else:
                next_marble_index = (current_marble_index + 1 + 1) % (len(marbles))
                marbles.insert(next_marble_index, i)
                current_marble_index = next_marble_index

            i += 1

    return max(player_score)



if __name__ == "__main__":
    main()