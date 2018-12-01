#include <iostream>
#include <fstream>
#include <string>
#include <map>
#include <vector>

int main()
{
    std::ifstream fileInput;
    fileInput.open("input");

    if (fileInput.is_open())
    {
        std::string line;
        std::vector<int> input;

        // Read contents of file and stores it in a vector
        while (std::getline(fileInput, line))
        {
            input.push_back(atoi(line.c_str()));
        }
        fileInput.close();


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
    }

    else std::cout << "Unable to open file!";

    return 0;
}