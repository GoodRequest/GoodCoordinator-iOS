//
//  RouteType.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

public protocol RouteType {

    associatedtype CoordinatorType: Coordinator
    associatedtype ScreenType: Screen
    associatedtype Options

    associatedtype InputType

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>)
    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>, options: Options)

    var options: Options { get }
    var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType> { get }

    func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType
    func apply(coordinator: CoordinatorType, input: InputType)

}

public extension RouteType where Options == Void {

    init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>, options: Options) {
        self.init(wrappedValue: wrappedValue)
    }

}

public extension RouteType {

    func prepareScreen(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = screenBuilder(coordinator)(input)
        if let screen = screen as? any Coordinator {
            screen.parent = coordinator
        }
        return screen
    }

    func apply(coordinator: CoordinatorType, input: InputType) {
        _ = apply(coordinator: coordinator, input: input) as ScreenType
    }

}
