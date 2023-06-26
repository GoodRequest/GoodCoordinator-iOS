//
//  NavigationRouter.swift
//  NavigationApp
//
//  Created by Filip Šašala on 09/05/2023.
//

import SwiftUI

protocol Routable: ObservableObject {

}

final class WeakRef<T: AnyObject> {
    weak var value: T?

    init(value: T) {
        self.value = value
    }
}

final class NavigationRouter<T>: Routable {

    public let id: Int
    public var coordinator: T {
        _coordinator.value as! T
    }

    private var _coordinator: WeakRef<AnyObject>

    public init(id: Int, coordinator: T) {
        self.id = id
        self._coordinator = WeakRef(value: coordinator as AnyObject)
    }

}

extension NavigationRouter where T: NavigationCoordinator {

//    func route<U: RouteType, Input, Output: View>(
//        to route: KeyPath<T, GRTransition<T, U, Input, Output>>,
//        _ input: Input
//    ) -> T {
//        return coordinator.route(to: route, input)
//    }

}
