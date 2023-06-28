//
//  Typealiases.swift
//  NavigationApp
//
//  Created by Filip Šašala on 28/06/2023.
//

import Foundation

typealias VoidClosure = () -> Void

typealias ScreenBuilder<CoordinatorType, InputType> = ((CoordinatorType) -> ((InputType) -> any Screen))
typealias VoidScreenBuilder<CoordinatorType> = ((CoordinatorType) -> () -> any Screen)
