#include <iostream>
#include <string>
#include <unordered_set>
#include <vector>

#include <chrono>

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
    for (const auto& var : input)
    {
        total += var;
    }
    std::cout << total << '\n';


    // Calculates puzzle 2;
    std::unordered_set<int> duplicates{};
    constexpr int n262144 = 2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2;
    duplicates.reserve(n262144);
    int current = 0;
    bool found = false;

    auto begin = std::chrono::steady_clock::now();
    while (!found)
    {
        for (const auto& var : input)
        {
            current += var;
            if (!duplicates.insert(current).second) {
                found = true;
                break;                
            }
        }
    }
    auto end = std::chrono::steady_clock::now();
    std::cout << "T2 = " << std::chrono::duration_cast<std::chrono::microseconds>(end - begin).count() << "us\n";

    std::cout << current << " " << duplicates.size() <<'\n';
    return 0;
}
