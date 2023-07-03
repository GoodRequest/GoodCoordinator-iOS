//
//  RouteType.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

// ----------------

protocol RouteType {

    associatedtype CoordinatorType: Coordinator

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, CoordinatorType.Input>)

    var screenBuilder: ScreenBuilder<CoordinatorType, CoordinatorType.Input> { get }
    func apply(coordinator: CoordinatorType, input: CoordinatorType.Input, keyPath: AnyKeyPath)

}

extension RouteType {

    func prepareScreen(coordinator: CoordinatorType, input: CoordinatorType.Input) -> any Screen {
        let screen = screenBuilder(coordinator)(input)
        if var screen = screen as? any Coordinator {
            screen.parent = coordinator
        }
        return screen
    }

}

extension RouteType where CoordinatorType.Input == Void {

    init(wrappedValue: @escaping VoidScreenBuilder<CoordinatorType>) {
        self.init(wrappedValue: { (coordinator: CoordinatorType) in
            return { (_: ()) -> any Screen in
                return wrappedValue(coordinator)()
            }
        })
    }

    func apply(coordinator: CoordinatorType, keyPath: AnyKeyPath) {
        apply(coordinator: coordinator, input: (), keyPath: keyPath)
    }

}

// ----------------

typealias RootStep<CoordinatorType: Coordinator> = NavigationStep<Root<CoordinatorType>>
typealias PushStep<CoordinatorType: NavigationCoordinator> = NavigationStep<Push<CoordinatorType>>
typealias PresentStep<CoordinatorType: PresentationCoordinator> = NavigationStep<Present<CoordinatorType>>

@propertyWrapper final class NavigationStep<Route: RouteType> {

    var wrappedValue: Route

    init(_ screen: @escaping ScreenBuilder<Route.CoordinatorType, Route.CoordinatorType.Input>) {
        self.wrappedValue = Route.init(wrappedValue: screen)
    }

}

extension NavigationStep where Route.CoordinatorType.Input == Void {

    convenience init(_ screen: @escaping VoidScreenBuilder<Route.CoordinatorType>) {
        self.init { (coordinator: Route.CoordinatorType) in
            return { (_: ()) -> any Screen in
                return screen(coordinator)()
            }
        }
    }

}

// ----------------

struct Root<CoordinatorType: Coordinator>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, CoordinatorType.Input>

    init(wrappedValue: @escaping (CoordinatorType) -> ((CoordinatorType.Input) -> any Screen)) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: CoordinatorType.Input, keyPath: AnyKeyPath) {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.setRoot(to: screen)
    }

}


struct Push<CoordinatorType: NavigationCoordinator>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, CoordinatorType.Input>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, CoordinatorType.Input>) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: CoordinatorType.Input, keyPath: AnyKeyPath) {
        coordinator.state.items.append(NavigationStackItem(
            keyPath: keyPath,
            input: input,
            screen: prepareScreen(coordinator: coordinator, input: input)
        ))
    }

}

struct Present<CoordinatorType: PresentationCoordinator>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, CoordinatorType.Input>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, CoordinatorType.Input>) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: CoordinatorType.Input, keyPath: AnyKeyPath) {
        coordinator.state.present(PresentationItem(
            keyPath: keyPath,
            input: input,
            screen: prepareScreen(coordinator: coordinator, input: input)
        ))
    }

}
