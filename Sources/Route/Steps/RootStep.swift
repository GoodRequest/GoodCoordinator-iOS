//
//  RootStep.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 31/07/2023.
//

public struct RootStep<CoordinatorType: Coordinator, ScreenType: Screen, InputType>: RouteType {

    public var options: Void
    public var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType>

    public init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>) {
        self.screenBuilder = wrappedValue
        self.options = ()
    }

    public func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let screen = prepareScreen(coordinator: coordinator, input: input)
        coordinator.setRoot(to: screen)

        return screen
    }

}
