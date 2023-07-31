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

public final class Router<CoordinatorType: Coordinator>: ObservableObject {

    public let coordinator: CoordinatorType

    internal init(coordinator: CoordinatorType) {
        self.coordinator = coordinator
    }

}
