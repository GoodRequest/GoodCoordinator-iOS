//
//  PresentationCoordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 03/07/2023.
//

import SwiftUI

// MARK: - Presentation coordinator

public protocol PresentationCoordinator: Coordinator where State: PresentationState {

    associatedtype RootType: Screen
    var root: RootStep<Self, RootType, Input> { get }
    init()

}

public extension PresentationCoordinator where Input == Void {

    init() {
        self.init(())
    }

}

// MARK: - Protocol requirements

public extension PresentationCoordinator {

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
        state.root.screen.makeView()
            .modifier(PresentationCoordinatorViewWrapper(coordinator: self))
    }

    func abortChild() {
        if canDismissChild() {
            dismissChild()
        }
    }

    func setRoot(to screen: any Screen) {
        state.root = RootItem(screen: screen)
    }

}

// MARK: - Presentation functions - public

public extension PresentationCoordinator {

    func dismiss() {
        parent?.abortChild()
    }

    func dismissChild() {
        state.dismissChild()
    }

}

// MARK: - Helper functions - public

public extension PresentationCoordinator {

    func canBeDismissed() -> Bool {
        (parent as? any PresentationCoordinator)?.canDismissChild() ?? false
    }

    func canDismissChild() -> Bool {
        state.canDismissChild()
    }

    func isPresented() -> Bool {
        (parent as? (any PresentationCoordinator))?.isPresenting() ?? false
    }

    func isPresenting() -> Bool {
        state.isPresenting()
    }

}
