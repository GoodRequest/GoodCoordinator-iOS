//
//  Tree.swift
//  NavigationApp
//
//  Created by Filip Šašala on 02/05/2023.
//

import Foundation

typealias Tree<Value> = Node<Value>

final class Node<Value> {

    var value: Value
    private(set) var children: [Node]

    var count: Int {
        1 + children.reduce(0) { $0 + $1.count }
    }

    var hasSingleChild: Bool {
        children.count <= 1
    }

    var firstChild: Node? {
        return children.first
    }

    var lastLeaf: Node {
        var lastLeaf = self
        while let nextLeaf = firstChild {
            lastLeaf = nextLeaf
        }
        return lastLeaf
    }

    init(_ value: Value) {
        self.value = value
        children = []
    }

    init(_ value: Value, children: [Node]) {
        self.value = value
        self.children = children
    }

    init(_ value: Value, @NodeBuilder builder: () -> [Node]) {
        self.value = value
        self.children = builder()
    }

    func add(child: Node) {
        children.append(child)
    }

}

extension Node: Equatable where Value: Equatable {

    static func ==(lhs: Node, rhs: Node) -> Bool {
        lhs.value == rhs.value && lhs.children == rhs.children
    }

}

extension Node: Hashable where Value: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(children)
    }

}

extension Node: Codable where Value: Codable {}

extension Node where Value: Equatable {

    subscript(_ value: Value) -> Node? {
        find(value)
    }

    func find(_ value: Value) -> Node? {
        if self.value == value {
            return self
        }

        for child in children {
            if let match = child.find(value) {
                return match
            }
        }

        return nil
    }

}

@resultBuilder
struct NodeBuilder {

    static func buildBlock<Value>(_ children: Node<Value>...) -> [Node<Value>] {
        children
    }

}
