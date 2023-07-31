//
//  Typealiases.swift
//  NavigationApp
//
//  Created by Filip Šašala on 28/06/2023.
//

typealias VoidClosure = () -> Void

typealias ScreenBuilder<CoordinatorType, InputType, ResultType> = ((CoordinatorType) -> ((InputType) -> ResultType))
typealias VoidScreenBuilder<CoordinatorType, ResultType> = ((CoordinatorType) -> () -> ResultType)

typealias Root<
    CoordinatorType: Coordinator,
    ScreenType: Screen,
    InputType
> = NavigationStep<RootStep<CoordinatorType, ScreenType, InputType>>

typealias Push<
    CoordinatorType: NavigationCoordinator,
    ScreenType: Screen,
    InputType
> = NavigationStep<PushStep<CoordinatorType, ScreenType, InputType>>

typealias Present<
    CoordinatorType: PresentationCoordinator,
    ScreenType: Coordinator,
    InputType
> = NavigationStep<PresentStep<CoordinatorType, ScreenType, InputType>>
