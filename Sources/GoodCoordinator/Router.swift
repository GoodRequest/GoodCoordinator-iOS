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

    public func route<R: Reactor>(_ reactor: R.Type = R.self, _ destination: R.Destination) {
        Task { await self.route(reactor, destination) }
    }

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
    public func route<R: Reactor>(_ reactor: R.Type = R.self, _ destination: R.Destination) async -> Bool {
        // find the requested reactor in the tree
        let lastFoundReactor = navigationPath.root.depthFirstSearch(NavigationStep(), predicate: { lhs, rhs in
            guard let rReactor = rhs.reactor else { return false }
            return rReactor.is(ofType: reactor)
        })

        // abort when reactor is not present
        guard let lastFoundReactor else { return false }

        // check if reactor is already presenting something
        if let currentDestination = lastFoundReactor.value.currentDestination {
            let requestedDestination = (destination as! AnyDestination)
            // Non-tab destinations do not need to be routed again when already presented.
            // Tabs still need to flow through the mutator so an inactive tab can become active again.
            // Compare via AnyHashable for correct value equality (hashValue alone can collide).
            if AnyHashable(currentDestination) == AnyHashable(requestedDestination), !(destination is any Tabs) {
                return true
            }

            // go to bottom-most node under this reactor
            let bottomMost = bottomMostDescendant(from: lastFoundReactor)

            // pop towards the reactor asynchronously
            let popped = await popTo(reactor, from: bottomMost)

            // navigate on the target reactor
            lastFoundReactor.value.mutator?(requestedDestination)

            // cleanup when switching contexts
            if !popped {
                cleanup()
            }

            return true
        } else {
            // reactor has no destination, we can navigate directly
            lastFoundReactor.value.mutator?((destination as! AnyDestination))
            return true
        }
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
                success = await route(type, destination)
                if !success {
                    await Task.yield()
                }
            } while !success && attempts < 10
        }
    }

    /// Pops the current destination from the navigation hierarchy.
    ///
    /// Performs a single back navigation step. If the current screen is presenting a destination,
    /// the presentation is cleared; otherwise the screen itself is dismissed by its parent.
    /// Does nothing when already at the root level.
    public func pop() {
        let currentDepth = navigationPath.lastActiveNode.depth
        guard currentDepth > 1 else { return }
        pop(node: navigationPath.lastActiveNode)
    }

    /// Pops multiple destinations from the navigation hierarchy.
    ///
    /// Pops up to `count` steps back. Between each step, this function yields to the main
    /// run loop, allowing the UI to update its state. If `count` exceeds the available depth,
    /// this operation pops to the root.
    ///
    /// - Parameters:
    ///   - count: The number of steps to pop. Defaults to 1.
    public func pop(last count: Int = 1) async {
        let currentDepth = navigationPath.lastActiveNode.depth
        guard currentDepth > 1 else { return }
        guard count < currentDepth else { return await pop(last: currentDepth - 1) }

        for _ in 0..<count {
            guard pop(node: navigationPath.lastActiveNode) else { return }
            await Task.yield()
        }
    }

    /// Pops back to the nearest destination whose reactor matches the given type.
    ///
    /// If a match is found, screens are popped one by one, yielding to the main run loop between steps.
    /// If no matching destination exists, no action is taken.
    ///
    /// - Parameters:
    ///   - reactor: The reactor type to pop to
    public func popTo<R: Reactor>(_ reactor: R.Type) async {
        let currentNode = navigationPath.lastActiveNode
        await popTo(reactor, from: currentNode)
    }

    /// Drops inactive navigation branches (including tabs) and preserves only the active path.
    ///
    /// Use this to reset previous tab and screen state once a new path becomes active. It is
    /// safe to call after switching tabs or routing across tabs to forget the previous tab’s
    /// state. This is also appropriate after major context changes (for example, transitioning
    /// from a logged-out flow to a logged-in flow, or resetting an onboarding).
    ///
    /// Notes:
    /// - Internally, the navigation tree is pruned to keep only the path from root to the last
    ///   active node, effectively resetting tabs.
    /// - When context tabs are switched, sibling tabs are marked inactive. Calling
    ///   `cleanup()` prunes those inactive siblings and any inactive branches, effectively
    ///   removing old branches and inactive tabs while keeping the current tab/screen intact.
    /// - The currently active screen and tab remain unchanged.
    /// - The function is idempotent, calling it when there are no inactive branches is a no-op.
    public func cleanup() {
        navigationPath.cleanup()
    }

}

// MARK: - Private

private extension Router {

    func bottomMostDescendant(from node: TreeNode<NavigationStep>) -> TreeNode<NavigationStep> {
        var currentNode = node
        while true {
            if currentNode.value.isTabs {
                // prefer active tabs, else take first
                if let active = currentNode.children.first(where: { $0.value.isActive }) {
                    currentNode = active
                } else if let first = currentNode.children.first {
                    currentNode = first
                } else {
                    break
                }
            } else {
                // always take first child if it exists
                if let first = currentNode.children.first {
                    currentNode = first
                } else {
                    break
                }
            }
        }
        return currentNode
    }

    @discardableResult
    func pop(node currentNode: TreeNode<NavigationStep>) -> Bool {
        guard let parentNode = currentNode.parent else {
            // cannot pop root
            return false
        }

        if parentNode.value.isTabs {
            if currentNode.value.currentDestination != nil && !currentNode.value.isTabs {
                // even when parent is a tab, it may be presenting something directly
                currentNode.value.mutator?(nil)
                return true
            } else {
                // tab is not presenting anything
                popTabAttemptDetected()
                return false
            }
        } else {
            if currentNode.value.currentDestination != nil && !currentNode.value.isTabs {
                // current node is a screen and is presenting something directly
                currentNode.value.mutator?(nil)
                return true
            } else {
                // current node is a screen and is not presenting, popped from parent
                parentNode.value.mutator?(nil)
                return true
            }
        }
    }

    @discardableResult
    func popTo<R: Reactor>(_ reactor: R.Type, from node: TreeNode<NavigationStep>) async -> Bool {
        // find nearest matching ancestor starting from 'from'
        var current: TreeNode<NavigationStep>? = node
        var targetNode: TreeNode<NavigationStep>? = nil
        while let candidate = current {
            if candidate.value.reactor?.is(ofType: reactor) ?? false {
                targetNode = candidate
                break
            }
            current = candidate.parent
        }
        guard let targetNode else { return false }

        // pop until we reach the target reactor
        // attempt counter to avoid infinite loops
        var attempts = 255
        while attempts > 0 {
            attempts -= 1
            // bottom-most under target
            let bottom = bottomMostDescendant(from: targetNode)

            // target has no children, stop
            if bottom === targetNode { return true }

            // pop one step and yield
            guard pop(node: bottom) else { return false }
            await Task.yield()
        }

        // attempts exceeded
        return false
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
