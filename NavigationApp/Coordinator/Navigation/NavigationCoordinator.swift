//
//  NavigationCoordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI // TODO: treba? vyhodit prec 2x View

protocol NavigationCoordinator: PresentationCoordinator where State: NavigationStack {

    associatedtype RootType: View
    var root: Root<Self, RootType, Input> { get }
    init()

}

extension NavigationCoordinator where Input == Void {

    init() {
        self.init(())
    }

}

extension NavigationCoordinator {

    init(_ input: Input) {
        self.init()

        setRoot(to: root.prepareScreen(coordinator: self, input: input))
    }

    var parent: (any Coordinator)? {
        get {
            return state.parent
        } set {
            state.parent = newValue
        }
    }

    @ViewBuilder var body: some View {
        if #available(iOS 16, *) {
            SwiftUI.NavigationStack {
                state.screenWithId(-1)
                    .modifier(PresentationCoordinatorViewWrapper(coordinator: self))
                    .modifier(NavigationCoordinatorViewWrapper(id: -1, coordinator: self))
            }
        } else {
            SwiftUI.NavigationView {
                state.screenWithId(-1)
                    .modifier(PresentationCoordinatorViewWrapper(coordinator: self))
                    .modifier(NavigationCoordinatorViewWrapper(id: -1, coordinator: self))
            }.navigationViewStyle(.stack)
        }
    }

    func canPopTo(id: Int) -> Bool {
        state.canPopTo(id: id)
    }

    internal func popTo(_ int: Int, _ action: (() -> ())? = nil) {
//        if let action = action {
//            self.stack.dismissalAction[int] = action
//        }
//
//        guard int + 1 <= self.stack.value.count else {
//            return
//        }
//
//        if int == -1 {
//            self.stack.value = []
//            self.stack.poppedTo.send(-1)
//        } else if int >= 0 {
//            self.stack.value = Array(self.stack.value.prefix(int + 1))
//            self.stack.poppedTo.send(int)
//        }
        state.pop(to: int)
    }

    func setRoot(to screen: any Screen) {
        state.root = NavigationRootItem(screen: screen)
    }

    func abortChild() {
        if canDismissChild() {
            dismissChild()
        } else {
            pop()
        }
    }

    func pop() {
        if state.items.isEmpty {
            parent?.abortChild()
        } else {
            popTo((state.items.count - 1 /* Index */) - 1 /* Previous */ )
        }
    }

    func popToRoot() {
        popTo(-1, nil)
    }

}
