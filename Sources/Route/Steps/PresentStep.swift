//
//  PresentStep.swift
//  NavigationApp
//
//  Created by Filip Šašala on 31/07/2023.
//

public struct PresentStep<CoordinatorType: PresentationCoordinator, ScreenType: Coordinator, InputType>: RouteType {

    public var options: PresentationStyle
    public var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType>

    public init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>) {
        self.screenBuilder = wrappedValue
        self.options = .sheet
    }

    public init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>, options: PresentationStyle) {
        self.screenBuilder = wrappedValue
        self.options = options
    }

    public func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.state.present(PresentationItem(
            input: input,
            style: options,
            screen: screen
        ))

        return screen
    }

}
