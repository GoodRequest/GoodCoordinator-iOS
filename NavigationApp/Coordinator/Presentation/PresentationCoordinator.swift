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

    @Published var root: NavigationRootItem
    @Published var presented: [PresentationItem<Any>] = [] // covariant

    init() {
        self.root = NavigationRootItem(screen: EmptyView())
    }

    func present(_ item: PresentationItem<Any>) {
        guard presented.count < 1 else { preconditionFailure("Presenting multiple windows is not supported") }
        presented.append(item)
    }

    func dismiss() {
        guard presented.count <= 1 else { preconditionFailure("Presenting multiple windows is not supported") }
        presented = []
    }

}

// MARK: - Protocol declaration

protocol PresentationCoordinator: Coordinator where State: PresentationState {

    associatedtype RootType: View
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
