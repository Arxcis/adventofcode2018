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
    //constexpr int n262144 = 2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2;
    //std::unordered_set<int> duplicates{};
    //duplicates.reserve(n262144);
    
    constexpr int32_t n32768  = 2*2*2*2*2*2*2*2*2*2*2*2*2*2*2;
    constexpr int32_t n524288 = 2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2;

    int32_t bit_field[n32768] = {};
    int32_t current = 0;
    bool found = false;

    auto begin = std::chrono::steady_clock::now();
    while (!found)
    {
        for (const auto& var : input)
        {
            current += var;
            const int32_t field_index = (current + n524288) / 32;
            const int32_t bit_index = (current + n524288) % 32;

            if (bit_field[field_index] & (0b1 << bit_index)) {
                found = true;
                break;
            }
            bit_field[field_index] |= (0b1 << bit_index);
        }
    }
    auto end = std::chrono::steady_clock::now();
    std::cout << "T2 = " << std::chrono::duration_cast<std::chrono::microseconds>(end - begin).count() << "us\n";

    std::cout << current <<'\n';
    return 0;
}
