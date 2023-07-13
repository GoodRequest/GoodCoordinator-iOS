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

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>) -> Self where Transition.CoordinatorType.Input == Void
    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>, _ input: Transition.CoordinatorType.Input) -> Self

}

extension Coordinator {

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>) -> Self where Transition.CoordinatorType.Input == Void {
        self.route(to: route, ())
    }

    func route<Transition: RouteType>(
        to route: KeyPath<Self, Transition>,
        _ input: Transition.CoordinatorType.Input
    ) -> Self {
        guard self is Transition.CoordinatorType else { fatalError("Unsupported transition") } // TODO: type check?

        let transition = self[keyPath: route]

        transition.apply(
            coordinator: (self as! Transition.CoordinatorType),
            input: input,
            keyPath: route
        )

        return self
    }

}

#warning("is required?")
protocol StringIdentifiable: Identifiable<String> {}
