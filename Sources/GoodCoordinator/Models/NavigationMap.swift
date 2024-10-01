//
//  NavigationMap.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 26/09/2024.
//

import GoodReactor
import GoodLogger

// MARK: - Navigation map

@MainActor struct NavigationMap {

    let root: Tree = Tree(value: NavigationStep(isActive: true))

    #warning("TODO: Implement performance optimizations")
//    var nodeMap: [AnyReactor: TreeNode<NavigationStep>] = [:]

    var lastActiveNode: TreeNode<NavigationStep> {
        var currentNode = root
        while let active = currentNode.children.first(where: { $0.value.isActive }) {
            currentNode = active
        }
        return currentNode
    }

    // MARK: - Logging

    private let logger = OSLogLogger()

    private func logNavigationTreeState() {
        logger.log(level: .debug, message: root.description, privacy: .auto)
    }

    // MARK: - Insert

    @discardableResult
    mutating func insert<R: Reactor>(reactor: R) -> TreeNode<NavigationStep>? {
        let newNode = TreeNode(value: NavigationStep(
            reactor: reactor,
            isActive: true,
            mutator: { [weak reactor] in reactor?.destination = $0 as! R.Destination? }
        ))

        // insert only when really required
        guard lastActiveNode.value.currentDestination != nil else {
            return nil
        }

        lastActiveNode.addChild(newNode)
//        nodeMap[reactor] = newNode

        logNavigationTreeState()
        return newNode
    }

    @discardableResult
    mutating func insertTab<R: Reactor>(reactor: R, destination: R.Destination) -> TreeNode<NavigationStep>? {
        let newNode = TreeNode(value: NavigationStep(
            reactor: reactor,
            currentDestination: destination as! AnyDestination?,
            isTabs: true,
            isActive: true,
            mutator: { [weak reactor] in reactor?.destination = $0 as! R.Destination? }
        ))

        let step = NavigationStep(reactor: reactor)
        let searchResult = root.breadthFirstSearch(step, predicate: NavigationStep.reactorEquals)

        if let searchResult, let parent = searchResult.parent {
            parent.addChild(newNode)
        } else if lastActiveNode.value.currentDestination != nil || lastActiveNode === root {
            lastActiveNode.addChild(newNode)
        } else {
            return nil
        }

        logNavigationTreeState()
        return newNode
    }

    // MARK: - Get

    nonmutating func get<R: Reactor>(for reactor: R) -> TreeNode<NavigationStep>? {
//        if let node = nodeMap[reactor], node.value.isActive {
//            return node
//        } else {
            let step = NavigationStep(reactor: reactor, isActive: true)
            let searchResult = root.breadthFirstSearch(step, predicate: NavigationStep.reactorEqualsActive)
            return searchResult
//        }
    }

    nonmutating func getTab<R: Reactor>(for reactor: R, destination: R.Destination) -> TreeNode<NavigationStep>? {
        let step = NavigationStep(reactor: reactor, currentDestination: (destination as! AnyDestination))
        let searchResult = root.breadthFirstSearch(step, predicate: NavigationStep.equals)
        return searchResult
    }

    // MARK: - Get or insert

    mutating func getOrInsert<R: Reactor>(for reactor: R) -> TreeNode<NavigationStep>? {
        return get(for: reactor) ?? insert(reactor: reactor)
    }

    mutating func getTabOrInsert<R: Reactor>(for reactor: R, destination: R.Destination) -> TreeNode<NavigationStep>? {
        return getTab(for: reactor, destination: destination) ?? insertTab(reactor: reactor, destination: destination)
    }

    // MARK: - Update

    mutating func updateDestination<R: Reactor>(to destination: R.Destination?, for reactor: R) {
        guard let node = getOrInsert(for: reactor) else { return }

        node.value.currentDestination = destination as! AnyDestination?
        node.value.isActive = true

        node.children.forEach {
            if let reactor = $0.value.reactor {
//                nodeMap.removeValue(forKey: reactor)
            }
        }
        node.children.removeAll()

        logNavigationTreeState()
    }

    mutating func updateTab<R: Reactor>(to tab: R.Destination, for reactor: R) {
        guard let node = getTabOrInsert(for: reactor, destination: tab) else { return }

        node.peers.forEach {
            $0.value.isActive = false
        }
        node.value.isActive = true

        logNavigationTreeState()
    }

    // MARK: - Cleanup

    mutating func cleanup() {
        var node = lastActiveNode
        node.children.removeAll()

        while let parent = node.parent {
            parent.children.removeAll(where: { !($0 === node) })
            node = parent
        }

        logNavigationTreeState()
    }

}
