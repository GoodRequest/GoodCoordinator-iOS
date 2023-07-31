//
//  Router.swift
//  NavigationApp
//
//  Created by Filip Šašala on 09/05/2023.
//

import Foundation

final class WeakRef<T: AnyObject> {
    weak var value: T?

    init(value: T) {
        self.value = value
    }
}

final class Router<CoordinatorType: Coordinator>: ObservableObject {

    let coordinator: CoordinatorType

    init(coordinator: CoordinatorType) {
        self.coordinator = coordinator
    }

}
