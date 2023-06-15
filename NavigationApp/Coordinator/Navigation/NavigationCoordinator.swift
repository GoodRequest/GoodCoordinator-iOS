//
//  NavigationCoordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI // TODO: treba? vyhodit prec 2x View

protocol NavigationCoordinator: Coordinator {

    var stack: NavigationStack<Self> { get }

}

extension NavigationCoordinator {

    weak var parent: (any Coordinator)? {
        get {
            return stack.parent
        } set {
            stack.parent = newValue
        }
    }

    var body: some View {
        NavigationCoordinatorViewWrapper(id: -1, coordinator: self)
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
        if let action = action {
            self.stack.dismissalAction[int] = action
        }

        guard int + 1 <= self.stack.value.count else {
            return
        }

        if int == -1 {
            self.stack.value = []
            self.stack.poppedTo.send(-1)
        } else if int >= 0 {
            self.stack.value = Array(self.stack.value.prefix(int + 1))
            self.stack.poppedTo.send(int)
        }
    }

    func setupRoot() {
        let x = self[keyPath: self.stack.initial] as! NavigationOutputable
        let presentable = x.using(coordinator: self, input: self.stack.initialInput as Any)

        let item = NavigationRootItem(
            keyPath: self.stack.initial.hashValue,
            input: self.stack.initialInput,
            screen: presentable
        )

        self.stack.root = NavigationRoot(item: item)
    }

    func popToRoot() {
        popTo(-1, nil)
    }

    func route<U: RouteType, Input, Output: View>(
        to route: KeyPath<Self, GRTransition<Self, U, Input, Output>>,
        _ input: Input
    ) -> Self {
        let transition = self[keyPath: route]
        let output = transition.closure(self)(input)
        self.stack.value.append(NavigationStackItem(
            keyPath: route.hashValue,
            input: input,
            screen: output
        ))

        return self
    }

}
