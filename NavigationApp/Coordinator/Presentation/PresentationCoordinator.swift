//
//  PresentationCoordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 03/07/2023.
//

import SwiftUI

struct PresentationItem<Input> {

    let keyPath: AnyKeyPath
    let input: Input
    var screen: any Screen // child?
    var dismissAction: VoidClosure? = nil

}


class PresentationState: ObservableObject {

    var parent: (any Coordinator)?

    @Published var root: NavigationRootItem
    @Published var presented: [PresentationItem<Any>] = [] // covariant

    init() {
        self.root = NavigationRootItem(screen: EmptyView())
    }

    func present(_ item: PresentationItem<Any>) {
        guard presented.count < 1 else { fatalError("Presenting multiple windows is not supported") }
        presented.append(item)
    }

    func dismiss() {
        guard presented.count <= 1 else { fatalError("Presenting multiple windows is not supported") }
        presented = []
    }

}

// MARK: - Protocol declaration

protocol PresentationCoordinator: Coordinator where State: PresentationState {

    var root: Root<Self> { get }
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
        AnyView(state.root.screen).modifier(PresentationCoordinatorViewWrapper(coordinator: self))
    }

    init(_ input: Input) {
        self.init()

        setRoot(to: root.prepareScreen(coordinator: self, input: input))
    }

    func setRoot(to screen: any Screen) {
        state.root = NavigationRootItem(screen: screen)
    }

    func abortChild() {
        state.dismiss()
    }

    func dismiss() {
        parent?.abortChild()
    }

}

extension PresentationCoordinator {

    func isPresenting() -> Binding<Bool> {
        Binding(get: {
            state.presented.count == 1
        }, set: {
            guard !$0 else { return }
            state.dismiss()
        })
    }

}
