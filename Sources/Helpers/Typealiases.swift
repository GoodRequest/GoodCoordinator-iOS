//
//  Typealiases.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 28/06/2023.
//

public typealias VoidClosure = () -> Void

public typealias ScreenBuilder<CoordinatorType, InputType, ResultType> = ((CoordinatorType) -> ((InputType) -> ResultType))
public typealias VoidScreenBuilder<CoordinatorType, ResultType> = ((CoordinatorType) -> () -> ResultType)

public typealias Root<
    CoordinatorType: Coordinator,
    ScreenType: Screen,
    InputType
> = NavigationStep<RootStep<CoordinatorType, ScreenType, InputType>>

public typealias Push<
    CoordinatorType: NavigationCoordinator,
    ScreenType: Screen,
    InputType
> = NavigationStep<PushStep<CoordinatorType, ScreenType, InputType>>

public typealias Present<
    CoordinatorType: PresentationCoordinator,
    ScreenType: Coordinator,
    InputType
> = NavigationStep<PresentStep<CoordinatorType, ScreenType, InputType>>
