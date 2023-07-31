//
//  NavigationCoordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI // TODO: treba? vyhodit prec 2x View

protocol NavigationCoordinator: PresentationCoordinator where State: NavigationStack {

    associatedtype RootType: Screen
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

    func makeView() -> AnyView {
        return AnyView(body)
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
        let rootIndex = -1

        state.screenWithId(rootIndex).makeView()
            .modifier(PresentationCoordinatorViewWrapper(coordinator: self))
            .modifier(NavigationCoordinatorViewWrapper(id: rootIndex, coordinator: self))
    }

    #warning("TODO: doplnit lepsiu heuristiku ak sa da, toto zatial postacuje")
    private func hasNavigationParent() -> Bool {
        let hasParent = (parent != nil)
        guard hasParent else { return false }

        guard !isPresented() else { return false }
        return true
    }

    func canPopToScreen(with id: Int) -> Bool {
        let isValidIndex = state.isValidIndex(id: id)
        let isPresenting = state.isPresenting()

        return isValidIndex && !isPresenting
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
        state.root = CoordinatorRootItem(screen: screen)
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
