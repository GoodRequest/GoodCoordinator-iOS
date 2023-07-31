//
//  PresentationCoordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 03/07/2023.
//

import SwiftUI

enum PresentationStyle: Equatable {

    case sheet
    case fullScreenCover
    case popover
    case inspector

}

struct PresentationItem<Input> {

    let input: Input
    let style: PresentationStyle

    var screen: any Screen // child?
    var dismissAction: VoidClosure? = nil

}

class PresentationState: ObservableObject {

    var parent: (any Coordinator)?

    @Published var root: CoordinatorRootItem
    @Published var presented: [PresentationItem<Any>] = [] { // covariant
        willSet {
            print("Will set on: \(address(of: self))")
        }
        didSet {
            print("Presentation state: \(oldValue.count == 1) -> \(presented.count == 1)")
        }
    }

    init() {
        self.root = CoordinatorRootItem(screen: EmptyView())
        print("+ init \(address(of: self))")
    }

    deinit {
        print("- deinit \(address(of: self))")
    }

    func present(_ item: PresentationItem<Any>) {
        guard presented.count < 1 else { preconditionFailure("Presenting multiple windows is not supported") }
        presented.append(item)
    }

    func dismissChild() {
        guard presented.count <= 1 else { preconditionFailure("Presenting multiple windows is not supported") }
        presented = []
    }

    func canDismissChild() -> Bool {
        presented.count == 1
    }

    func isPresenting() -> Bool {
        canDismissChild()
    }

}

// MARK: - Protocol declaration

protocol PresentationCoordinator: Coordinator where State: PresentationState {

    associatedtype RootType: Screen
    var root: Root<Self, RootType, Input> { get }
    init()

}

extension PresentationCoordinator where Input == Void {

    init() {
        self.init(())
    }

}

// MARK: - Protocol requirements

extension PresentationCoordinator {

    var parent: (any Coordinator)? {
        get {
            state.parent
        }
        set {
            state.parent = newValue
        }
    }

    @ViewBuilder var body: some View {
        AnyView(state.root.screen.makeView()).modifier(PresentationCoordinatorViewWrapper(coordinator: self))
    }

    init(_ input: Input) {
        self.init()

        setRoot(to: root.prepareScreen(coordinator: self, input: input))
    }

    func setRoot(to screen: any Screen) {
        state.root = CoordinatorRootItem(screen: screen)
    }

    func canDismissChild() -> Bool {
        state.canDismissChild()
    }

    func canBeDismissed() -> Bool {
        (parent as? any PresentationCoordinator)?.canDismissChild() ?? false
    }

    func abortChild() {
        if canDismissChild() {
            dismissChild()
        }
    }

    func dismiss() {
        parent?.abortChild()
    }

    func dismissChild() {
        state.dismissChild()
    }

    func isPresenting() -> Bool {
        state.isPresenting()
    }

    func isPresented() -> Bool {
        (parent as? (any PresentationCoordinator))?.isPresenting() ?? false
    }

}
