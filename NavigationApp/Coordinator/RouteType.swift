//
//  RouteType.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

// ----------------

protocol RouteType {

    associatedtype CoordinatorType: Coordinator
    associatedtype ScreenType: Screen

    associatedtype InputType
    // associatedtype ResultType

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>)

    var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType> { get }

    func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType
    func apply(coordinator: CoordinatorType, input: InputType)

}

extension RouteType {

    func prepareScreen(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = screenBuilder(coordinator)(input)
        if var screen = screen as? any Coordinator {
            screen.parent = coordinator
        }
        return screen
    }

}

extension RouteType where InputType == Void {

    init(wrappedValue: @escaping VoidScreenBuilder<CoordinatorType, ScreenType>) {
        self.init(wrappedValue: { (coordinator: CoordinatorType) in
            return { (_: ()) -> ScreenType in
                return wrappedValue(coordinator)()
            }
        })
    }

    func apply(coordinator: CoordinatorType) -> ScreenType {
        return apply(coordinator: coordinator, input: ())
    }

    func apply(coordinator: CoordinatorType) {
        apply(coordinator: coordinator, input: ()) as Void
    }

}

// ----------------

typealias RootStep<
    CoordinatorType: Coordinator,
    ScreenType: Screen,
    InputType
> = NavigationStep<Root<CoordinatorType, ScreenType, InputType>>

typealias PushStep<
    CoordinatorType: NavigationCoordinator,
    ScreenType: Screen,
    InputType
> = NavigationStep<Push<CoordinatorType, ScreenType, InputType>>

typealias PresentStep<
    CoordinatorType: PresentationCoordinator,
    ScreenType: Coordinator,
    InputType
> = NavigationStep<Present<CoordinatorType, ScreenType, InputType>>

@propertyWrapper final class NavigationStep<Route: RouteType> {

    var wrappedValue: Route

    init(_ screen: @escaping ScreenBuilder<Route.CoordinatorType, Route.InputType, Route.ScreenType>) {
        self.wrappedValue = Route.init(wrappedValue: screen)
    }

}

extension NavigationStep where Route.InputType == Void {

    convenience init(_ screen: @escaping VoidScreenBuilder<Route.CoordinatorType, Route.ScreenType>) {
        self.init { (coordinator: Route.CoordinatorType) in
            return { (_: ()) -> Route.ScreenType in
                return screen(coordinator)()
            }
        }
    }

}

// ----------------

struct Root<CoordinatorType: Coordinator, ScreenType: Screen, InputType>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.setRoot(to: screen)

        return screen
    }

    func apply(coordinator: CoordinatorType, input: InputType) {
        fatalError()
    }

}

struct Present<CoordinatorType: PresentationCoordinator, ScreenType: Coordinator, InputType>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.state.present(PresentationItem(
            input: input,
            screen: screen
        ))

        return screen
    }

    func apply(coordinator: CoordinatorType, input: InputType) {
        fatalError()
    }

}

struct Push<CoordinatorType: NavigationCoordinator, ScreenType: Screen, InputType>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.state.push(items: [
            NavigationStackItem(
                input: input,
                screen: screen
            )
        ])

        return screen
    }

    func apply(coordinator: CoordinatorType, input: InputType) {
        fatalError()
    }

}
