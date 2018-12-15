#include <iostream>
#include <string>
#include <set>
#include <vector>
#include <sstream>
#include <unordered_map>
#include <unordered_set>

int main(int argc, char** argv)
{   
    // ... read input
    struct Point{
        int x = INT_MAX;
        int y = INT_MAX;
        int manhattan_distance = INT_MAX;
    };

    const auto points = ([](){
        auto _points = std::vector<Point>{};
        for (std::string line; std::getline(std::cin, line); ) {
            auto p = Point{};
            sscanf(line.c_str(), "%d, %d", &p.x, &p.y);
            _points.emplace_back(p);
        }
        return _points;
    })();

    //
    // ------------- Part1 ----------------
    //
    // ...find perimeter rectangle top,left,right,bottom
    struct Rect {
        int top = INT_MAX; 
        int left = INT_MAX; 
        int right = INT_MIN; 
        int bottom = INT_MIN;
    };
    auto rect = Rect{};
    for (const Point& p: points) {
        if (p.x < rect.left) {
            rect.left = p.x;
        }
        if (p.x > rect.right) {
            rect.right = p.x;
        }
        if (p.y < rect.top) {
            rect.top = p.y;
        }
        if (p.y > rect.bottom) {
            rect.bottom = p.y;
        }
    }

    // ...initialize grid within the perimeter
    struct ManhattanDistance { 
        int id = -1; 
        int distance = INT_MAX; 
    };
    const auto WIDTH = rect.right - rect.left;
    const auto HEIGHT = rect.bottom - rect.top;
    auto grid = std::vector<std::vector<ManhattanDistance>>{};
    for (int y = 0; y < HEIGHT; ++y) {
        auto inner = std::vector<ManhattanDistance>{};
        for (int x = 0; x < WIDTH; ++x) {
            inner.emplace_back(ManhattanDistance{});
        }
        grid.emplace_back(inner);
    }

    // ...find closest point to any grid-xy
    for (int y = 0; y < HEIGHT; ++y) {
        for (int x = 0; x < WIDTH; ++x) {
            for (int pindex = 0; pindex < points.size(); ++pindex) {
                const auto& p = points[pindex];
                const auto manhattan_distance = abs(p.x - x) + abs(p.y - y);
                if (manhattan_distance < grid[y][x].distance) {
                    grid[y][x] = ManhattanDistance{
                        pindex, 
                        manhattan_distance
                    };
                }
                else if (manhattan_distance == grid[y][x].distance 
                && pindex != grid[y][x].id) {
                    grid[y][x] = ManhattanDistance{
                        -1, 
                        manhattan_distance
                    };
                }
            }
        }
    }

    // ..find points with infinite surrounding area by traversing the perimeter
    auto infinites = std::unordered_set<int>{};
    for (int x = 0; x < WIDTH; ++x) {
        infinites.insert(grid[0][x].id);
        infinites.insert(grid[HEIGHT-1][x].id);
    }
    for (int y = 0; y < HEIGHT; ++y) {
        infinites.insert(grid[y][0].id);
        infinites.insert(grid[y][WIDTH-1].id);
    }

    // ...the points NOT in infinites has a finite area
    auto finiteAreas = std::unordered_map<int,int>{};
    for (int pindex = 0; pindex < points.size(); ++pindex) {
        if (infinites.find(pindex) == infinites.end()) {
            finiteAreas[pindex] = 0;
        }
    }

    // ... measure area of the finite points
    for (int y = 0; y < HEIGHT; ++y) {
        for (int x = 0; x < WIDTH; ++x) {
            if (infinites.find(grid[y][x].id) == infinites.end()) {
                finiteAreas[grid[y][x].id] += 1;
            }
        }
    }

    // ... find biggest area
    int max_id = -1;
    int max_area = INT_MIN;    
    for (const auto& area: finiteAreas) {
        if (area.second > max_area) {
            max_id = area.first;
            max_area = area.second;
        }
    }
    printf("%d\n", max_area);

    //
    // ------------- Part2 ----------------
    //
    // ... sum up all distances
    int regionSize = 0;
    for (int y = 0; y < HEIGHT; ++y) {
        for (int x = 0; x < WIDTH; ++x) {
            int sum = 0;
            for (int pindex = 0; pindex < points.size(); ++pindex) {
                const auto& p = points[pindex];
                sum += abs(p.x - x) + abs(p.y - y);
            }
            if (sum < 10000) {
                regionSize += 1;
            }
        }
    }
    printf("%d\n", regionSize);
}
