//
//  RouteType.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

// ----------------

protocol RouteType {

    associatedtype CoordinatorType: Coordinator
    associatedtype ResultType: Screen

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, CoordinatorType.Input, ResultType>)

    var screenBuilder: ScreenBuilder<CoordinatorType, CoordinatorType.Input, ResultType> { get }
    func apply(coordinator: CoordinatorType, input: CoordinatorType.Input, keyPath: KeyPath<CoordinatorType, ResultType>) -> ResultType

}

extension RouteType {

    func prepareScreen(coordinator: CoordinatorType, input: CoordinatorType.Input) -> ResultType {
        let screen = screenBuilder(coordinator)(input)
        if var screen = screen as? any Coordinator {
            screen.parent = coordinator
        }
        return screen
    }

}

extension RouteType where CoordinatorType.Input == Void {

    init(wrappedValue: @escaping VoidScreenBuilder<CoordinatorType, ResultType>) {
        self.init(wrappedValue: { (coordinator: CoordinatorType) in
            return { (_: ()) -> ResultType in
                return wrappedValue(coordinator)()
            }
        })
    }

    func apply(coordinator: CoordinatorType, keyPath: KeyPath<CoordinatorType, ResultType>) -> ResultType {
        apply(coordinator: coordinator, input: (), keyPath: keyPath)
    }

}

// ----------------

typealias RootStep<CoordinatorType: Coordinator, ResultType: Screen> = NavigationStep<Root<CoordinatorType, ResultType>>
typealias PushStep<CoordinatorType: NavigationCoordinator, ResultType: Screen> = NavigationStep<Push<CoordinatorType, ResultType>>
typealias PresentStep<CoordinatorType: PresentationCoordinator, ResultType: Coordinator> = NavigationStep<Present<CoordinatorType, ResultType>>

@propertyWrapper final class NavigationStep<Route: RouteType> {

    var wrappedValue: Route

    init(_ screen: @escaping ScreenBuilder<Route.CoordinatorType, Route.CoordinatorType.Input, Route.ResultType>) {
        self.wrappedValue = Route.init(wrappedValue: screen)
    }

}

extension NavigationStep where Route.CoordinatorType.Input == Void {

    convenience init(_ screen: @escaping VoidScreenBuilder<Route.CoordinatorType, Route.ResultType>) {
        self.init { (coordinator: Route.CoordinatorType) in
            return { (_: ()) -> Route.ResultType in
                return screen(coordinator)()
            }
        }
    }

}

// ----------------

struct Root<CoordinatorType: Coordinator, ResultType: Screen>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, CoordinatorType.Input, ResultType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, CoordinatorType.Input, ResultType>) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: CoordinatorType.Input, keyPath: KeyPath<CoordinatorType, ResultType>) -> ResultType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.setRoot(to: screen)

        return screen
    }

}

struct Present<CoordinatorType: PresentationCoordinator, ResultType: Coordinator>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, CoordinatorType.Input, ResultType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, CoordinatorType.Input, ResultType>) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: CoordinatorType.Input, keyPath: KeyPath<CoordinatorType, ResultType>) -> ResultType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.state.present(PresentationItem(
            keyPath: keyPath,
            input: input,
            screen: screen
        ))

        return screen
    }

}

struct Push<CoordinatorType: NavigationCoordinator, ResultType: Screen>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, CoordinatorType.Input, ResultType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, CoordinatorType.Input, ResultType>) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: CoordinatorType.Input, keyPath: KeyPath<CoordinatorType, ResultType>) -> ResultType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.state.push(items: [
            NavigationStackItem(
                keyPath: keyPath,
                input: input,
                screen: screen
            )
        ])

        return screen
    }

}
