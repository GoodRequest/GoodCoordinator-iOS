//
//  NavigationCoordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI // TODO: treba? vyhodit prec 2x View

protocol NavigationCoordinator: PresentationCoordinator where State: NavigationStack {

    var root: Root<Self> { get }
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

//    func dismissChild<T: Coordinator>(coordinator: T, action: (() -> Void)? = nil) {
//        guard let value = stack.value.firstIndex(where: { item in
//            guard let presentable = item.presentable as? (any StringIdentifiable) else {
//                return false
//            }
//
//            return presentable.id == coordinator.id
//        }) else {
//            assertionFailure("Can not dismiss child when coordinator is top of the stack.")
//            return
//        }
//
//        self.popTo(value - 1, action)
//    }

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

        print("[\(type(of: self))] Popping to \(int)")
        state.pop(to: int)
    }

    func setRoot(to screen: any Screen) {
        // let x = self[keyPath: self.stack.initial] as! NavigationOutputable
        // let presentable = x.using(coordinator: self, input: self.stack.initialInput as Any)

        // let rootScreen = self[keyPath: self.stack.initial](self)("")
//        let rootRoute = self[keyPath: self.state.root.keyPath] as! Root<Self, Input>
//        let rootScreen = rootRoute.prepareScreen(coordinator: self, input: self.state.root.input)
//        let rootScreen = rootRoute(self)(self.state.root.input)

//        let item = NavigationRootItem(
//            keyPath: self.state.root.keyPath.hashValue,
//            input: self.state.root.input,
//            screen: rootScreen
//        )

//        self.state.root.screen = rootScreen
        state.root = NavigationRootItem(screen: screen)
    }

    func abortChild() {
        if !state.presented.isEmpty {
            state.dismiss()
        } else {
            pop()
        }
    }

    func pop() {
        if state.items.isEmpty {
            parent?.abortChild()
        } else {
            popTo(state.items.count - 2)
        }
    }

    func popToRoot() {
        popTo(-1, nil)
    }

}
