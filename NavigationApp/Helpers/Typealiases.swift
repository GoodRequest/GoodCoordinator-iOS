//
//  Typealiases.swift
//  NavigationApp
//
//  Created by Filip Šašala on 28/06/2023.
//

import Foundation

typealias VoidClosure = () -> Void

typealias ScreenBuilder<CoordinatorType, InputType, ResultType> = ((CoordinatorType) -> ((InputType) -> ResultType))
typealias VoidScreenBuilder<CoordinatorType, ResultType> = ((CoordinatorType) -> () -> ResultType)
