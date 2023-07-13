//
//  NavigationRouter.swift
//  NavigationApp
//
//  Created by Filip Šašala on 09/05/2023.
//

import SwiftUI

final class WeakRef<T: AnyObject> {
    weak var value: T?

    init(value: T) {
        self.value = value
    }
}

protocol Router: ObservableObject {

    associatedtype CoordinatorType

    var coordinator: CoordinatorType { get }

}

final class PresentationRouter<CoordinatorType: PresentationCoordinator>: Router {

    var coordinator: CoordinatorType

    init(coordinator: CoordinatorType) {
        self.coordinator = coordinator
    }

}

final class NavigationRouter<CoordinatorType: NavigationCoordinator>: Router {

    public var coordinator: CoordinatorType

    public init(coordinator: CoordinatorType) {
        self.coordinator = coordinator
    }

}
