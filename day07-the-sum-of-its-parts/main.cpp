#include <iostream>
#include <string>
#include <unordered_set>
#include <set>
#include <vector>
#include <algorithm>

int main()
{   
    //
    // Part 0 - read input
    //
    const auto input = ([](){
        auto line = std::string{};
        auto input = std::vector<std::string>{};
        for (; std::getline(std::cin, line);) {
            input.emplace_back(line);
        }
        return input;
    })();

    // ...Condition is what needs to happen before something else
    struct Condition {
        char before{};
        char after{};
        bool unlocked = false;
    };

    // ... sorted set, important alphabetiacally sorted
    auto initialUnvisitedLetters = std::set<char>{};  
    auto initialConditions = std::vector<Condition>{};

    // ...parse input, fill allLettesr set
    for (const auto& line : input) {
        auto c = Condition{};
        sscanf(
            line.c_str(), 
            "Step %c must be finished before step %c can begin.", 
            &c.before, &c.after);
        initialUnvisitedLetters.insert(c.before);
        initialUnvisitedLetters.insert(c.after);
        initialConditions.emplace_back(c);
    }

    //
    // Part 1
    //
    // ...visit letter by letter using the algorithm
    // Algorithm:
    // 1. Find first letter which exist in 'before' but NOT in 'after'
    // 2. Mark letter as visited
    // 3. Repeat number 1 and 2, skip visited letters
    // 4. Exit when all letters visited
    //
    {
        auto unvisitedLetters = initialUnvisitedLetters;
        auto conditions = initialConditions;
        auto visitedLetters = std::string{};
        while (unvisitedLetters.size() > 1) {
            auto unvisitedLettersCopy = unvisitedLetters;
            for (const char letter : unvisitedLettersCopy) {
                bool found = false;
                for (const Condition& condition : conditions) {
                    found |= (!condition.unlocked && condition.after == letter);
                }
                // ...if not found in any after, means that this letter is safe to visit
                if (!found) {
                    // ...set all conditions from this letter as unlocked
                    for (Condition& condition : conditions) {
                        condition.unlocked |= condition.before == letter;
                    }
                    // ...mark letter as visited
                    unvisitedLetters.erase(letter);
                    visitedLetters += letter;
                    break;
                }
            }
        }
        // ... if only a single letter left
        visitedLetters += *(unvisitedLetters.begin());
        printf("%s\n", visitedLetters.c_str());
    }

    //
    // Part 2
    //
    // Have a worker pool to work on tasks in 'parallell'
    {
        const int WORKER_COUNT = 5;
        int time = 0;
        int task[WORKER_COUNT]    = {0,0,0,0,0};
        int workers[WORKER_COUNT] = {0,0,0,0,0};
        auto unvisitedLetters = initialUnvisitedLetters;
        auto conditions = initialConditions;

        while (unvisitedLetters.size() > 0) {
            auto unvisitedLettersCopy = unvisitedLetters;
            for (const char letter : unvisitedLettersCopy) {
                bool foundAfter = false;
                for (const auto& condition : conditions) {
                    foundAfter |= (!condition.unlocked && condition.after == letter);
                }
                // ...if not foundAfter in any after, means that this letter is safe to visit
                if (!foundAfter) {
                    for (int i = 0; i < WORKER_COUNT; ++i) {
                        // ...if worker is idle
                        if (workers[i] == 0) {
                            workers[i] = letter  - 'A' + 1 + 60;
                            task[i] = letter;
                            // ...mark letter as visited
                            unvisitedLetters.erase(letter);
                            break;
                        }
                    }
                }
            }
            bool didSubtract = false;
            // ...decrement time for all active workers
            for (int i = 0; i < WORKER_COUNT; ++i) {
                if (workers[i] > 0) {
                    workers[i]--;
                    didSubtract = true;
 
                    // ...worker completed task
                    if (workers[i] == 0) {
                        // ...set all conditions from this letter as unlocked
                        for (auto& condition : conditions) {
                            condition.unlocked |= condition.before == task[i];
                        }
                    }
                }
            }
            // ... increment time
            time += didSubtract;
        }

        // ... find worker with most time left and add to time
        bool stillTimeLeft = true;
        int maxTimeLeft = 0;
        for (int i = 0; i < WORKER_COUNT; ++i) {
            if (maxTimeLeft < workers[i]) {
                maxTimeLeft = workers[i];
            }
        }
        time += maxTimeLeft;

        printf("%d\n", time);
    }
}
