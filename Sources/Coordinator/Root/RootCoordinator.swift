//
//  RootCoordinator.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 01/08/2023.
//

import SwiftUI

public typealias SimpleCoordinator = RootCoordinator

public protocol RootCoordinator: Coordinator where State == SimpleState {

    associatedtype RootType: Screen
    var root: RootStep<Self, RootType, Input> { get }
    init()
    
}

public extension RootCoordinator where Input == Void {

    init() {
        self.init(())
    }

}

// MARK: - Protocol requirements

public extension RootCoordinator {

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
            .environmentObject(Router(coordinator: self))
    }

    func abortChild() {}

    func reset() {
        if let visibleCoordinator = state.root.screen as? any Coordinator {
            visibleCoordinator.reset()
        }
    }

    func setRoot(to screen: any Screen) {
        state.root = RootItem(screen: screen)
    }

}
