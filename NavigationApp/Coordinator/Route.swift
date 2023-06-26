//
//  Route.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

//typealias RootRoute<T: Coordinator, Input> = Route2<Root<T, Input>>
//typealias PushRoute<T: Coordinator, Input, Output: Screen> = Route<T, Present, Input, Output>
//typealias PresentRoute<T: Coordinator, Input, Output: Screen> = Route<T, Present, Input, Output>

//@propertyWrapper class Route<T: Coordinator, U: RouteType, Input, Output: Screen> {
//
//    public var wrappedValue: GRTransition<T, U, Input, Output>
//
//    init(wrappedValue: GRTransition<T, U, Input, Output>) {
//        self.wrappedValue = wrappedValue
//    }
//
//}
//
//extension Route where T: Coordinator, Input == Void , Output == AnyView {
//
//    convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> (() -> ViewOutput))) {
//        self.init(wrappedValue: GRTransition(type: U.init(), closure: { coordinator in
//            return { _ in AnyView(wrappedValue(coordinator)()) }
//        }))
//    }
//
//}

//@propertyWrapper class Route2<U: RouteType> {
//
//    public var wrappedValue: U
//
//    init(wrappedValue: U) {
//        self.wrappedValue = wrappedValue
//    }
//
//}
//
//extension Route2 where U.InputType == Void {
//
//    convenience init(wrappedValue: @escaping ScreenBuilder<U.CoordinatorType, U.InputType>) {
////        self.init(wrappedValue: GRTransition(type: U.init(), closure: { coordinator in
////            return { _ in AnyView(wrappedValue(coordinator)()) }
////        }))
//
//        self.init(wrappedValue: U.init(transitionTo: wrappedValue))
//    }
//
//}
