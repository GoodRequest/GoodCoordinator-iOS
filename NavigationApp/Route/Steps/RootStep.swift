//
//  RootStep.swift
//  NavigationApp
//
//  Created by Filip Šašala on 31/07/2023.
//

struct RootStep<CoordinatorType: Coordinator, ScreenType: Screen, InputType>: RouteType {

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
