//
//  NavigationStep.swift
//  NavigationApp
//
//  Created by Filip Šašala on 31/07/2023.
//

@propertyWrapper public final class NavigationStep<Route: RouteType> {

    public var wrappedValue: Route

    public init(_ screen: @escaping ScreenBuilder<Route.CoordinatorType, Route.InputType, Route.ScreenType>) {
        self.wrappedValue = Route.init(wrappedValue: screen)
    }

    public init(_ screen: @escaping ScreenBuilder<Route.CoordinatorType, Route.InputType, Route.ScreenType>, _ options: Route.Options) {
        self.wrappedValue = Route.init(wrappedValue: screen, options: options)
    }

}

public extension NavigationStep where Route.InputType == Void {

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
