//
//  Route.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

typealias RootRoute<T: Coordinator, Input, Output: Screen> = Route<T, Root, Input, Output>
typealias PresentRoute<T: Coordinator, Input, Output: Screen> = Route<T, Present, Input, Output>

@propertyWrapper class Route<T: Coordinator, U: RouteType, Input, Output: Screen> {

    public var wrappedValue: GRTransition<T, U, Input, Output>

    init(wrappedValue: GRTransition<T, U, Input, Output>) {
        self.wrappedValue = wrappedValue
    }

}

extension Route where T: Coordinator, Input == Void , Output == AnyView {

    convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> (() -> ViewOutput))) {
        self.init(wrappedValue: GRTransition(type: U.init(), closure: { coordinator in
            return { _ in AnyView(wrappedValue(coordinator)()) }
        }))
    }

}
