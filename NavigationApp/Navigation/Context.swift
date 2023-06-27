//
//  Context.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI
import Combine

/// A Coordinator usually represents some kind of flow in the app. You do not need to implement this directly if you're not toying with other types of navigation e.g. a hamburger menu, but rather you would implement TabCoordinatable, NavigationCoordinatable or ViewCoordinatable.



// ----------------

//protocol NavigationOutputable {
//
//    func using(coordinator: Any, input: Any) -> any Screen
//
//}
//
//struct GRTransition<T: Coordinator, U: RouteType, Input, Output: Screen>: NavigationOutputable {
//
//    let type: U
//    let closure: ((T) -> ((Input) -> Output))
//
//    func using(coordinator: Any, input: Any) -> any Screen {
//        if Input.self == Void.self {
//            return closure(coordinator as! T)(() as! Input)
//        } else {
//            return closure(coordinator as! T)(input as! Input)
//        }
//    }
//
//}

// ----------------

struct NavigationRootItem {
    let screen: any Screen
}

/// Wrapper around childCoordinators
/// Used so that you don't need to write @Published
public class NavigationRoot: ObservableObject {
    @Published var item: NavigationRootItem

    init(item: NavigationRootItem) {
        self.item = item
    }
}

class CoordinatorRoot: ObservableObject {

    

}

/*
/// Represents a stack of routes
class NavigationStack<T: NavigationCoordinator> {
    var dismissalAction: [Int: () -> Void] = [:]

    weak var parent: (any Coordinator)?
    var poppedTo = PassthroughSubject<Int, Never>()
    let initial: PartialKeyPath<T>
    let initialInput: Any?
    var root: NavigationRoot!

    @Published var value: [NavigationStackItem]

    public init(initial: PartialKeyPath<T>, _ initialInput: Any? = nil) {
        self.value = []
        self.initial = initial
        self.initialInput = initialInput
        self.root = nil
    }
}

/// Convenience checks against the navigation stack's contents
extension NavigationStack {
    /**
     The Hash of the route at the top of the stack
     - Returns: the hash of the route at the top of the stack or -1
     */
    var currentRoute: Int {
        return value.last?.keyPath ?? -1
    }

    /**
     Checks if a particular KeyPath is in a stack
     - Parameter keyPathHash:The hash of the keyPath
     - Returns: Boolean indiacting whether the route is in the stack
     */
    func isInStack(_ keyPathHash: Int) -> Bool {
        return value.contains { $0.keyPath == keyPathHash }
    }
}
*/
class NavigationStack<T: NavigationCoordinator, InputType>: ObservableObject {

    weak var parent: (any Coordinator)?

    @Published var root: NavigationRootItem
    @Published var items: [NavigationStackItem<Any>] = [] // covariant

    init() {
        self.root = NavigationRootItem(screen: EmptyView())
    }

    subscript(screenWithId id: Int) -> any Screen {
        if id == -1 {
            return root.screen
        } else {
            return items[safe: id]?.screen ?? EmptyView()
        }
    }

}

//extension NavigationStack where InputType == Void {
//
//    convenience init(root: KeyPath<T, Root<T, Void>>) {
//        self.init(root: root, input: ())
//    }
//
//}

struct NavigationStackItem<Input> {
    // let presentationType: PresentationType
    let keyPath: AnyKeyPath
    let input: Input
    var screen: any Screen // child?
}
