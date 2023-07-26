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

// MARK: - Navigation stack

class NavigationStack: PresentationState {

    @Published private(set) var items: [NavigationStackItem<Any>] = []  { // covariant
        willSet {
            print("Will set on: \(title)")
        }
        didSet {
            print("Navigation stack items: \(oldValue.count) -> \(items.count)")
        }
    }
    private var lastPoppedItem: (NavigationStackItem<Any>)?

    func screenWithId(_ id: Int) -> Screen {
        if id < -1 {
            let _ = assertionFailure("Invalid screen index!")
            return EmptyView()
        } else if id == -1 {
            return root.screen
        } else {
            let screen = items[safe: id]?.screen ?? lastPoppedItem?.screen ?? EmptyView()
            return screen
        }
    }

    let title: String
    init(string: String) {
        self.title = string

        super.init()
    }

}

// MARK: - Navigation

extension NavigationStack {

    func push(items newItems: [NavigationStackItem<Any>]) {
        items.append(contentsOf: newItems)
    }

    func pop(to id: Int) {
        let popIndex = id + 1
        if id == -1 && items.isEmpty {
            return assertionFailure("Already at root. Use `abortChild()` instead.")
        }
        guard items.startIndex..<items.endIndex ~= popIndex else {
            return assertionFailure("Invalid index. Use `abortChild()` instead.")
        }

        let rangeToPop = popIndex..<items.endIndex
        let itemsToPop = items[rangeToPop]
        lastPoppedItem = itemsToPop.first

        items.remove(atOffsets: IndexSet(integersIn: rangeToPop))
        itemsToPop.reversed().forEach { $0.dismissAction?() }
    }

    func revert() {
        guard let lastPoppedItem else { return }
        items.append(lastPoppedItem)
        self.lastPoppedItem = nil
    }

}

// MARK: - Helper functions

extension NavigationStack {

    func isValidIndex(id: Int) -> Bool {
        -1..<(items.endIndex - 1) ~= id
    }

    func top() -> NavigationStackItem<Any>? {
        items.last
    }

}

// MARK: - Navigation stack items

struct CoordinatorRootItem {

    let screen: any Screen

}

struct NavigationStackItem<Input> {

    let input: Input
    var screen: any Screen // child?
    var dismissAction: VoidClosure? = nil

}
