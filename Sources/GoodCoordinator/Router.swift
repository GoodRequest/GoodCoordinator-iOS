//
//  Router.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 12/09/2024.
//

import Collections
import GoodReactor
import IssueReporting

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

    /// Routes to a specified destination within a reactor. The reactor must be present in the navigation hierarchy.
    ///
    /// This function searches for the specified reactor type within the navigation hierarchy and attempts to route to
    /// the given destination if the reactor is found.
    ///
    /// - Parameters:
    ///   - reactor: The type of reactor to search for in the navigation hierarchy
    ///   - destination: The destination associated with the given reactor
    /// - Returns: `true` if routing succeeded (the reactor was found in the hierarchy), `false` otherwise
    @discardableResult
    public func route<R: Reactor>(_ reactor: R.Type = R.self, _ destination: R.Destination) -> Bool {
        let lastFoundReactor = navigationPath.root.depthFirstSearch(NavigationStep(), predicate: { lhs, rhs in
            guard let rReactor = rhs.reactor else { return false }
            return rReactor.is(ofType: reactor)
        })

        guard let lastFoundReactor else { return false }
        lastFoundReactor.value.mutator?((destination as! AnyDestination))

        return true
    }
    
    /// Routes through a path of destinations across multiple reactors.
    ///
    /// Routing starts with the first reactor, which must be present in the navigation hierarchy.
    /// For subsequent destinations, if their reactors are not in the navigation hierarchy, this function yields
    /// to the main run loop, allowing the UI to update its state. This process enables SwiftUI to create
    /// destination reactors from previous steps.
    ///
    /// - Parameters:
    ///   - type: A pack representing the reactors to route through
    ///   - destination: A pack representing the destinations associated with each reactor type
    public func route<each R: Reactor>(type: repeat (each R).Type, destination: repeat (each R).Destination) async {
        for (type, destination) in repeat (each type, each destination) {
            var attempts = 0
            var success = false
            repeat {
                attempts += 1
                success = route(type, destination)
                if !success {
                    await Task.yield()
                }
            } while !success || attempts > 10
        }
    }

    public func pop(last count: Int = 1) {
        let currentDepth = navigationPath.lastActiveNode.depth
        guard currentDepth > 1 else { return }
        guard count < currentDepth else { return pop(last: currentDepth - 1) }

        for _ in 0..<count {
            let currentNode = navigationPath.lastActiveNode
            let parentNode = currentNode.parent

            if let parentNode {
                if parentNode.value.isTabs {
                    // parent is tabs and screen may be presenting something directly
                    if currentNode.value.currentDestination != nil && !currentNode.value.isTabs {
                        currentNode.value.mutator?(nil)
                    } else {
                        popTabAttemptDetected()
                        return
                    }
                } else {
                    // current destination is a reactor, pop from parent
                    parentNode.value.mutator?(nil)
                }
            }
        }
    }

    public func cleanup() {
        navigationPath.cleanup()
    }

    public func popTo<R: Reactor>(_ reactor: R.Type) {
        var currentNode = navigationPath.lastActiveNode
        while var parentNode = currentNode.parent {
            if parentNode.value.isTabs {
                // parent is tabs, something is presented and presenting node has specified type
                if currentNode.value.currentDestination != nil && !currentNode.value.isTabs {
                    if currentNode.value.reactor?.is(ofType: reactor) ?? false {
                        currentNode.value.mutator?(nil)
                        return
                    } else {
                        currentNode = parentNode
                        continue
                    }
                } else {
                    popTabAttemptDetected()
                    return
                }
            } else {
                // current destination is a reactor, pop from parent if this is the expected destination
                // or continue searching up the hierarchy
                let parentReactor = parentNode.value.reactor
                if parentReactor?.is(ofType: reactor) ?? false {
                    parentNode.value.mutator?(nil)
                    return
                } else {
                    currentNode = parentNode
                    continue
                }
            }
        }
    }

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

// MARK: - Issue reporting

private extension Router {

    func popTabAttemptDetected() {
        IssueReporting.reportIssue(
            """
            Attempted to pop a tab - this is not allowed as tabs must always point to a valid \
            destination. Use #router.route(:,:) instead and specify the destination tab manually.
            
            If the current tab should forget its state after switching, use #router.cleanup()
            to allow the router to drop inactive tabs.
            """
        )
    }

}
