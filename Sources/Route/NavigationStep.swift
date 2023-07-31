//
//  NavigationStep.swift
//  NavigationApp
//
//  Created by Filip Šašala on 31/07/2023.
//

@propertyWrapper final class NavigationStep<Route: RouteType> {

    var wrappedValue: Route

    init(_ screen: @escaping ScreenBuilder<Route.CoordinatorType, Route.InputType, Route.ScreenType>) {
        self.wrappedValue = Route.init(wrappedValue: screen)
    }

    init(_ screen: @escaping ScreenBuilder<Route.CoordinatorType, Route.InputType, Route.ScreenType>, _ options: Route.Options) {
        self.wrappedValue = Route.init(wrappedValue: screen, options: options)
    }

}

extension NavigationStep where Route.InputType == Void {

    convenience init(_ screen: @escaping VoidScreenBuilder<Route.CoordinatorType, Route.ScreenType>) {
        self.init({ (coordinator: Route.CoordinatorType) in
            return { (_: ()) -> Route.ScreenType in
                return screen(coordinator)()
            }
        })
    }

    convenience init(_ screen: @escaping VoidScreenBuilder<Route.CoordinatorType, Route.ScreenType>, _ options: Route.Options) {
        self.init({ (coordinator: Route.CoordinatorType) in
            return { (_: ()) -> Route.ScreenType in
                return screen(coordinator)()
            }
        }, options)
    }

}
