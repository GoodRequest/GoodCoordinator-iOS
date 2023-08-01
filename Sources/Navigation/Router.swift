//
//  Router.swift
//  GoodCoordinator
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

    private weak var coordinatorContainer: CoordinatorType?

    internal init(coordinator: CoordinatorType) {
        self.coordinatorContainer = coordinator
    }

    public var coordinator: CoordinatorType {
        return coordinatorContainer ?? { fatalError("No router available") }()
    }

}
