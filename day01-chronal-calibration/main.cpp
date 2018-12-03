#include <iostream>
#include <string>
#include <set>
#include <vector>

int main(int argc, char** argv)
{
    std::vector<std::string> lines{};
    for (std::string line; std::getline(std::cin, line);) {
        lines.push_back(line);
    }

    std::string line;
    std::vector<int> input;
    for (const auto& line: lines) {
        input.push_back(atoi(line.c_str()));
    }

    // Calculates puzzle 1
    int total = 0;
    for (auto var : input)
    {
        total += var;
    }

    std::cout << total << '\n';


    // Calculates puzzle 2;
    std::set<int> duplicates;
    int current = 0;
    bool found = false;
    while (!found)
    {
        for (auto var : input)
        {
            current += var;

            if (duplicates.find(current) != duplicates.end()) {
                std::cout << current << '\n';
                found = true;
                break;                
            }
            
            duplicates.insert(current);
        }
    }
    return 0;
}
