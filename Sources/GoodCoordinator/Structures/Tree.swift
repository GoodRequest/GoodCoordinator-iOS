//
//  Tree.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 26/09/2024.
//

import Collections

public typealias Tree<T> = TreeNode<T>

// MARK: - Class

public class TreeNode<T> {
    public var value: T

    public weak var parent: TreeNode?
    public var children = [TreeNode<T>]()

    public var peers: [TreeNode<T>] {
        parent?.children.filter { !($0 === self) } ?? []
    }

    public init(value: T) {
        self.value = value
    }

    public func addChild(_ node: TreeNode<T>) {
        children.append(node)
        node.parent = self
    }
}

// MARK: - Depth

extension TreeNode {

    var depth: Int {
        var depth = 1
        var node = self
        while let nextNode = node.parent {
            node = nextNode
            depth += 1
        }
        return depth
    }

}

// MARK: - String description

extension TreeNode: CustomStringConvertible {

    public var description: String {
        var s = "\(value)"
        if !children.isEmpty {
            s += " { " + children.map { $0.description }.joined(separator: ", ") + " }"
        }
        return s
    }

}

// MARK: - Search

extension TreeNode {

    public func depthFirstSearch(_ value: T, predicate: (T, T) -> Bool) -> TreeNode? {
        if predicate(value, self.value) {
            return self
        }
        for child in children {
            if let next = child.depthFirstSearch(value, predicate: predicate) {
                return next
            }
        }
        return nil
    }

    public func breadthFirstSearch(_ value: T, predicate: (T, T) -> Bool) -> TreeNode? {
        var queue = Deque<TreeNode<T>>()
        queue.append(self)

        while let next = queue.popFirst() {
            if predicate(value, next.value) {
                return next
            }
            for child in next.children {
                queue.append(child)
            }
        }
        return nil
    }

}

extension TreeNode where T: Equatable {

    public func depthFirstSearch(_ value: T) -> TreeNode? {
        depthFirstSearch(value, predicate: ==)
    }

    public func breadthFirstSearch(_ value: T) -> TreeNode? {
        breadthFirstSearch(value, predicate: ==)
    }

}
