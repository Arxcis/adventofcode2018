#include <iostream>
#include <string>
#include <sstream>
#include <vector>

struct Node {
    using id = int;
    std::vector<id> children;
    std::vector<int> metadata;
    int value = 0;
};

 Node make_node(std::vector<Node>& nodes, std::stringstream& ss) {
    
    Node node{};
    int child_count{};
    int metadata_count{};
    ss >> child_count;
    ss >> metadata_count;

    for (int i = 0; i < child_count; ++i) {
        node.children.emplace_back(nodes.size());
        nodes.emplace_back(make_node(nodes, ss));
    }

    for (int i = 0; i < metadata_count; ++i) {
        int meta{};
        ss >> meta;
        node.metadata.emplace_back(meta);
    }
    return node;
};

int main() {

    //
    // Part 0: Read input
    //
    const auto input = ([](){
        auto input = std::string{};
        std::getline(std::cin, input);
        return input;
    })();

    //
    // Part 1: 
    //  ... parse nodes
    //  ... sum all metadata on each node
    //
    auto nodes = std::vector<Node>{};
    std::stringstream ss(input);
    nodes.emplace_back(make_node(nodes, ss));

    int sum = 0;
    for (const auto& node: nodes) {
        for (const auto meta: node.metadata) {
            sum += meta;
        }
    }
    printf("%d\n", sum);

    //
    // Part 2:
    //
}