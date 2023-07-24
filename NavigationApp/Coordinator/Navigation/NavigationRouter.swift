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

final class Router<CoordinatorType: Coordinator>: ObservableObject {

    private(set) var coordinator: CoordinatorType

    init(coordinator: CoordinatorType) {
        self.coordinator = coordinator
    }

}
