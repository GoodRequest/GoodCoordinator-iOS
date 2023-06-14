//
//  Context.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI
import Combine

//import Stinsen
//
//final class AppCoordinator: NavigationCoordinatable {
//
//    var stack: Stinsen.NavigationStack<AppCoordinator> = .init(initial: \Self.start)
//
//    @Root var start = makeStart
//    @Root var goToHome = makeHome
//
//    @ViewBuilder func makeStart() -> some View {
//        LoginView(model: LoginModel())
//    }
//
//    @ViewBuilder func makeHome() -> some View {
//        HomeView()
//    }
//
//}
//
//struct AppRouter<R>: Scene where R: Router {
//
//    private let rootRouters: [R]
//
//    var body: some Scene {
//        WindowGroup {
//            AppCoordinator().view()
//        }
//    }
//
//    init(@ArrayBuilder<R> rootRouters: () -> [R]) {
//        self.rootRouters = rootRouters()
//    }
//
//}



/// A Coordinatable usually represents some kind of flow in the app. You do not need to implement this directly if you're not toying with other types of navigation e.g. a hamburger menu, but rather you would implement TabCoordinatable, NavigationCoordinatable or ViewCoordinatable.
protocol Coordinatable: ObservableObject, StringIdentifiable, Identifiable, Screen, ChildDismissable {
    var parent: ChildDismissable? { get set }
}

extension Coordinatable {

    var id: String {
        return ObjectIdentifier(self).debugDescription // TODO: betterify
    }

}

protocol ChildDismissable: AnyObject {
    func dismissChild<T: Coordinatable>(coordinator: T, action: (() -> Void)?)
}

protocol StringIdentifiable: Identifiable<String> {

    var id: String { get }

}

// ----------------



protocol NavigationOutputable {

    func using(coordinator: Any, input: Any) -> any Screen

}

struct GRTransition<T: Coordinatable, U: RouteType, Input, Output: Screen>: NavigationOutputable {

    let type: U
    let closure: ((T) -> ((Input) -> Output))

    func using(coordinator: Any, input: Any) -> any Screen {
        if Input.self == Void.self {
            return closure(coordinator as! T)(() as! Input)
        } else {
            return closure(coordinator as! T)(input as! Input)
        }
    }

}

// ----------------



// ----------------

struct NavigationRootItem {
    let keyPath: Int
    let input: Any?
    let child: any Screen
}

/// Wrapper around childCoordinators
/// Used so that you don't need to write @Published
public class NavigationRoot: ObservableObject {
    @Published var item: NavigationRootItem

    init(item: NavigationRootItem) {
        self.item = item
    }
}

/// Represents a stack of routes
class NavigationStack<T: Coordinator> {
    var dismissalAction: [Int: () -> Void] = [:]

    weak var parent: ChildDismissable?
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

struct NavigationStackItem {
    // let presentationType: PresentationType
    let presentable: any Screen
    let keyPath: Int
    let input: Any?
}
