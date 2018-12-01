#include <iostream>
#include <string>
#include <map>
#include <vector>

int main(int argc, char** argv)
{
    if (argc < 2) {
        std::cerr << "Missing input\n";
        return 1;
    }

    std::string line;
    std::vector<int> input;
    for (int i = 1; i < argc; i++) {
        line = argv[i];
        input.push_back(atoi(line.c_str()));
    }

    // Calculates puzzle 1
    int total = 0;
    for (auto var : input)
    {
        total += var;
    }

    std::cout << "part1 " << total << '\n';


    // Calculates puzzle 2;
    std::map<int, int> duplicates;
    int current = 0;
    bool found = false;
    while (!found)
    {
        for (auto var : input)
        {
            current += var;
            auto ret = duplicates.insert(std::pair<int, int>(current, 1));
            if (ret.second == false)
            {
                std::cout << "part2 " << current << '\n';
                found = true;
                break;
            }
        }
    }
    return 0;
}