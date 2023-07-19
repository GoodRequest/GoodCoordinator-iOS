//
//  Coordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

protocol Coordinator: Screen {

    associatedtype State
    associatedtype Input

    init(_ input: Input)

    var parent: (any Coordinator)? { get set }
    var state: State { get set }

    /// Removes the last child from coordinator stack.
    /// Useful when popping from different coordinators
    /// or dismissing context.
    func abortChild()
    func setRoot(to: any Screen)

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>) -> Transition.ScreenType where Transition.InputType == Void
    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>, _ input: Transition.InputType) -> Transition.ScreenType

}

extension Coordinator {

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>) -> Transition.ScreenType where Transition.InputType == Void {
        self.route(to: route, ())
    }

    func route<Transition: RouteType>(
        to route: KeyPath<Self, Transition>,
        _ input: Transition.InputType
    ) -> Transition.ScreenType {
        guard self is Transition.CoordinatorType else { fatalError("Unsupported transition") } // TODO: type check?

        let transition = self[keyPath: route]

        let result: Transition.ScreenType = transition.apply(
            coordinator: (self as! Transition.CoordinatorType),
            input: input
        )

        return result
    }

}

#warning("is required?")
protocol StringIdentifiable: Identifiable<String> {}
