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
    associatedtype Options

    associatedtype InputType
    // associatedtype ResultType

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>)
    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>, options: Options)

    var options: Options { get }
    var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType> { get }

    func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType
    func apply(coordinator: CoordinatorType, input: InputType)

}

extension RouteType where Options == Void {

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>, options: Options) {
        self.init(wrappedValue: wrappedValue)
    }

}

extension RouteType {

    func prepareScreen(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = screenBuilder(coordinator)(input)
        if var screen = screen as? any Coordinator {
            screen.parent = coordinator
        }
        return screen
    }

    func apply(coordinator: CoordinatorType, input: InputType) {
        _ = apply(coordinator: coordinator, input: input) as ScreenType
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

// ----------------

struct Root<CoordinatorType: Coordinator, ScreenType: Screen, InputType>: RouteType {

    var options: Void
    var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>) {
        self.screenBuilder = wrappedValue
        self.options = ()
    }

    func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.setRoot(to: screen)

        return screen
    }

}

struct Present<CoordinatorType: PresentationCoordinator, ScreenType: Coordinator, InputType>: RouteType {

    var options: PresentationStyle
    var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>) {
        self.screenBuilder = wrappedValue
        self.options = .sheet
    }

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>, options: PresentationStyle) {
        self.screenBuilder = wrappedValue
        self.options = options
    }

    func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.state.present(PresentationItem(
            input: input,
            style: options,
            screen: screen
        ))

        return screen
    }

}

struct Push<CoordinatorType: NavigationCoordinator, ScreenType: Screen, InputType>: RouteType {

    var options: Void
    var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>) {
        self.screenBuilder = wrappedValue
        self.options = ()
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

}
