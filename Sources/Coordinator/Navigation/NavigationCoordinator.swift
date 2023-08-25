//
//  NavigationCoordinator.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

// MARK: - Navigation coordinator

public protocol NavigationCoordinator: PresentationCoordinator where State: NavigationStack {

    associatedtype RootType: Screen
    var root: RootStep<Self, RootType, Input> { get }
    init()

}

public extension NavigationCoordinator where Input == Void {

    init() {
        self.init(())
    }

}

// MARK: - Protocol requirements

public extension NavigationCoordinator {

    var parent: (any Coordinator)? {
        get {
            state.parent
        }
        set {
            state.parent = newValue
        }
    }

    init(_ input: Input) {
        self.init()

        setRoot(to: root.prepareScreen(coordinator: self, input: input))
    }

    func makeView() -> AnyView {
        AnyView(body)
    }

    @ViewBuilder var body: some View {
        if hasNavigationParent() {
            content
        } else if #available(iOS 16, *) {
            SwiftUI.NavigationStack { content }
        } else {
            SwiftUI.NavigationView { content }.navigationViewStyle(.stack)
        }
    }

    @ViewBuilder private var content: some View {
        let rootIndex = NavigationStack.rootIndex

        state.screenAtIndex(rootIndex).makeView()
            .modifier(PresentationCoordinatorViewWrapper(coordinator: self))
            .modifier(NavigationCoordinatorViewWrapper(id: rootIndex, coordinator: self))
    }

    func abortChild() {
        if canDismissChild() {
            dismissChild()
            return
        }

        let childIsCoordinator = state.top()?.screen is any Coordinator
        if childIsCoordinator {
            pop()
        }
    }

    func reset() {
        if canDismissChild() {
            dismissChild()
        }
        if canPopToScreen(with: NavigationStack.rootIndex) {
            popToRoot()
        }
    }

    func setRoot(to screen: Screen) {
        state.root = RootItem(screen: screen)
    }

}

// MARK: - Navigation functions - public

public extension NavigationCoordinator {

    #warning("TODO: Completion handler")

    func pop() {
        if state.items.isEmpty {
            parent?.abortChild()
        } else {
            popTo((state.items.count - 1 /* Count to index */) - 1 /* Previous */ )
        }
    }

    func popToRoot() {
        popTo(NavigationStack.rootIndex, nil)
    }

}

// MARK: - Navigation functions - internal

internal extension NavigationCoordinator {

    func popTo(_ int: Int, _ action: (() -> ())? = nil) {
        state.pop(to: int)
    }

}

// MARK: - Helper functions - internal

internal extension NavigationCoordinator {

    #warning("TODO: doplnit lepsiu heuristiku ak sa da, toto zatial postacuje")
    private func hasNavigationParent() -> Bool {
        let hasParent = (parent != nil)
        guard hasParent else { return false }

        guard !isPresented() else { return false }
        
        if parent is (any TabCoordinator) || parent is (any RootCoordinator) { return false }
        return true
    }

    func canPopToScreen(with index: Int) -> Bool {
        let isValidIndex = state.isValidIndex(index)
        let isPresenting = state.isPresenting()

        return isValidIndex && !isPresenting
    }

}
