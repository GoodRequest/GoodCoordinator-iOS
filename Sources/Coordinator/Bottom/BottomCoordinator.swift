//
//  BottomCoordinator.swift
//  
//
//  Created by Filip Šašala on 01/08/2023.
//

import SwiftUI

public protocol BottomCoordinator: Coordinator where State == BottomState {

    associatedtype RootType: Screen
    var root: RootStep<Self, RootType, Input> { get }
    init()
    
}

public extension BottomCoordinator where Input == Void {

    init() {
        self.init(())
    }

}

// MARK: - Protocol requirements

public extension BottomCoordinator {

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

    func abortChild() {
        fatalError("Bottom coordinator cannot have children")
    }

    func setRoot(to screen: any Screen) {
        state.root = RootItem(screen: screen)
    }

}
