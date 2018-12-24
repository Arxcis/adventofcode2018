#include <iostream>
#include <string>
#include <sstream>
#include <vector>

struct Node {
    using id = int;
    std::vector<id> children;
    std::vector<int> metadata;
};

 Node make_node(std::vector<Node>& nodes, std::stringstream& ss) {
    
    Node node{};
    int child_count{};
    int metadata_count{};
    ss >> child_count;
    ss >> metadata_count;

    for (int i = 0; i < child_count; ++i) {
        nodes.emplace_back(make_node(nodes, ss));
        node.children.emplace_back(nodes.size() - 1);
    }

    for (int i = 0; i < metadata_count; ++i) {
        int meta{};
        ss >> meta;
        node.metadata.emplace_back(meta);
    }
    return node;
};

int value_of(const Node& node, const std::vector<Node>& nodes) {

    int value = 0;

    // ... if no children
    if (node.children.size() == 0) {
        for (int i = 0; i < node.metadata.size(); ++i) {
            value += node.metadata[i];
        } 
    } else { // ... if has children
        for (int i = 0; i < node.metadata.size(); ++i) {
            // ... if metadata index within children index range
            if (0 < node.metadata[i] && node.metadata[i] <= node.children.size()) {
                int childIndex = node.metadata[i]-1;
                int nodeIndex = node.children[childIndex];
                auto child = nodes[nodeIndex];
                value += value_of(child, nodes);
            }
        }
    }
    return value;
}

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
    //
    // ...parse nodes
    // ...sum all metadata on each node
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
    // ...find value of the root node
    auto root = nodes[nodes.size()-1];
    int value_of_root_node = value_of(root, nodes);
    printf("%d\n", value_of_root_node);
}
