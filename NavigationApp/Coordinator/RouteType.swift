//
//  RouteType.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

// ----------------

protocol RouteType {

    associatedtype CoordinatorType: Coordinator
    associatedtype InputType

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType>)

    var screenBuilder: ScreenBuilder<CoordinatorType, InputType> { get }
    func apply(coordinator: CoordinatorType, input: InputType, keyPath: AnyKeyPath)

}

extension RouteType {

    func prepareScreen(coordinator: CoordinatorType, input: InputType) -> any Screen {
        return screenBuilder(coordinator)(input)
    }

}

extension RouteType where InputType == Void {

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

typealias RootStep<CoordinatorType: Coordinator, InputType> = NavigationStep<Root<CoordinatorType, InputType>>
typealias PushStep<CoordinatorType: NavigationCoordinator, InputType> = NavigationStep<Push<CoordinatorType, InputType>>

@propertyWrapper final class NavigationStep<Route: RouteType> {

    var wrappedValue: Route

    init(_ screen: @escaping ScreenBuilder<Route.CoordinatorType, Route.InputType>) {
        self.wrappedValue = Route.init(wrappedValue: screen)
    }

}

extension NavigationStep where Route.InputType == Void {

    convenience init(_ screen: @escaping VoidScreenBuilder<Route.CoordinatorType>) {
        self.init { (coordinator: Route.CoordinatorType) in
            return { (_: ()) -> any Screen in
                return screen(coordinator)()
            }
        }
    }

}

// ----------------

struct Root<CoordinatorType: Coordinator, InputType>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, InputType>

    init(wrappedValue: @escaping (CoordinatorType) -> ((InputType) -> any Screen)) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: InputType, keyPath: AnyKeyPath) {
        print("Pop all and switch root")

        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.setRoot(to: screen)
    }

}


struct Push<CoordinatorType: NavigationCoordinator, InputType>: RouteType {

    var screenBuilder: ScreenBuilder<CoordinatorType, InputType>

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType>) {
        self.screenBuilder = wrappedValue
    }

    func apply(coordinator: CoordinatorType, input: InputType, keyPath: AnyKeyPath) {
        coordinator.state.items.append(NavigationStackItem(
            keyPath: keyPath,
            input: input,
            screen: prepareScreen(coordinator: coordinator, input: input)
        ))
    }

}
