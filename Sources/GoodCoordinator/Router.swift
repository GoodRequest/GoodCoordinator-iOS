//
//  Router.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 12/09/2024.
//

import Collections
import GoodReactor

typealias AnyReactor = AnyHashable

private extension AnyReactor {

    func `as`<R: Reactor>(_ type: R.Type) -> R? {
        self as? R
    }

    func `is`<R: Reactor>(ofType: R.Type) -> Bool {
        self is R
    }

}

// MARK: - Router

@MainActor public final class Router {

    private var navigationPath = NavigationMap()

    public init() {}

    // MARK: - Public

    public func route<R: Reactor>(_ reactor: R.Type = R.self, _ destination: R.Destination) {
        route(type: reactor, destination: destination)
    }

    public func route<each R: Reactor>(type: repeat (each R).Type, destination: repeat (each R).Destination) {
        for (type, destination) in repeat (each type, each destination) {
            let lastSuchReactor = navigationPath.root.depthFirstSearch(NavigationStep(), predicate: { lhs, rhs in
                guard let rReactor = rhs.reactor else { return false }
                return rReactor.is(ofType: type)
            })

            guard let lastSuchReactor else { continue }
            lastSuchReactor.value.mutator?((destination as! AnyDestination))
        }
    }

    public func pop(last count: Int = 1) {
        let currentDepth = navigationPath.lastActiveNode.depth
        guard currentDepth > 1 else { return }
        guard count < currentDepth else { return pop(last: currentDepth - 1) }

        for _ in 0..<count {
            let lastActiveNodeParent = navigationPath.lastActiveNode.parent

            guard let lastActiveNodeParent, !lastActiveNodeParent.value.isTabs else { return }
            lastActiveNodeParent.value.mutator?(nil)
        }
    }

    public func cleanup() {
        navigationPath.cleanup()
    }

//    public func popTo<R: Reactor>(_ reactor: R.Type) {
//        let lastReactorIndex = navigationPath.count - 1
//        let poppingToReactorAtIndex = navigationPath.keys.lastIndex(where: { $0 is R }) ?? lastReactorIndex
//        navigationPath.removeLast(lastReactorIndex - poppingToReactorAtIndex)
//    }

}

// MARK: - GoodReactor internal

public extension Router {

    func getOrInsert<R: Reactor>(for reactor: R) -> R.Destination? {
        let tab: TreeNode<NavigationStep>?
        if let initialDestination = (R.Destination.self as? any Tabs.Type)?.initialDestination as? R.Destination {
            if let activeDestination = navigationPath.get(for: reactor) {
                tab = activeDestination
            } else {
                tab = navigationPath.getTabOrInsert(for: reactor, destination: initialDestination)
            }
        } else {
            tab = navigationPath.getOrInsert(for: reactor)
        }

        return tab?.value.currentDestination as! R.Destination?
    }

    func get<R: Reactor>(for reactor: R) -> R.Destination? {
        let tab: TreeNode<NavigationStep>?
        if let initialDestination = (R.Destination.self as? any Tabs.Type)?.initialDestination as? R.Destination {
            if let activeDestination = navigationPath.get(for: reactor) {
                tab = activeDestination
            } else {
                tab = navigationPath.getTab(for: reactor, destination: initialDestination)
            }
        } else {
            tab = navigationPath.get(for: reactor)
        }

        return tab?.value.currentDestination as! R.Destination?
    }

    func set<R: Reactor>(_ reactor: R, initial destination: AnyDestination?) {
        set(reactor, destination: destination as! R.Destination?)
    }

    func set<R: Reactor>(_ reactor: R, destination: R.Destination?) {
        if destination is any Tabs {
            guard let destination else { return }
            navigationPath.updateTab(to: destination, for: reactor)
        } else {
            navigationPath.updateDestination(to: destination, for: reactor)
        }
    }

}
