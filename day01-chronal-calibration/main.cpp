#include <iostream>
#include <string>
#include <vector>

int main()
{
    std::vector<std::string> lines{};
    for (std::string line; std::getline(std::cin, line);) 
    {
        lines.emplace_back(line);
    }

    std::string line;
    std::vector<int> input;
    for (const std::string& line: lines) 
    {
        input.emplace_back(atoi(line.c_str()));
    }

    //
    // Part1
    //
    int total = 0;
    for (const auto& var : input) 
    {
        total += var;
    }
    printf("%d\n", total);


    //
    // Part 2
    //
    constexpr int32_t n32768  = 2*2*2*2*2*2*2*2*2*2*2*2*2*2*2;
    constexpr int32_t n524288 = 2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2;

    int32_t bit_field[n32768] = {};
    int32_t current = 0;
    bool found = false;

    while (!found)
    {
        for (const auto& var : input)
        {
            current += var;
            const int32_t field_index = (current + n524288) >> 5;
            const int32_t bit_index = (current + n524288) % 32;

            if (bit_field[field_index] & (0b1 << bit_index)) {
                found = true;
                break;
            }
            bit_field[field_index] |= (0b1 << bit_index);
        }
    }
    printf("%d\n", current);
    return 0;
}
