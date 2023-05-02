//
//  Context.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI
/*
protocol Context: Identifiable {

    associatedtype ContentType: View
    var content: ContentType { get }

}

final class CurrentContext<ContextType: Context>: ObservableObject {

    @Published private(set) var id: ContextType.ID

    public init(_ id: ContextType.ID) {
        self.id = id
    }

    public func `switch`(to context: ContextType) {
        self.id = context.id
    }

}

struct AppContext<ContextType: Context>: Scene {

    @StateObject private var currentContext: CurrentContext<ContextType>
    private let contexts: [ContextType]

    var body: some Scene {
        WindowGroup {
            getCurrentContext()
        }
    }

    init(allAvailable available: [ContextType]) {
        guard !available.isEmpty else { fatalError("Cannot create AppContext without any context!") }

        self.contexts = available
        self._currentContext = StateObject(wrappedValue: CurrentContext(available.first!.id))
    }

    private func getCurrentContext() -> AnyView {
        guard let content = contexts.first(where: { $0.id == currentContext.id }) else {
            return AnyView(EmptyView())
        }

        return AnyView(content.content.environmentObject(currentContext))
    }

}
*/

protocol Route: Equatable {

    var id: UUID { get }

}

extension Route {

    func eraseToAnyRoute() -> AnyRoute {
        AnyRoute(self)
    }

}

extension Route where Self: Equatable {

    func equals<R>(other: R) -> Bool where R: Route {
        return id == other.id
    }

}

struct AnyRoute: Route {

    private let route: any Route

    init(_ other: any Route) {
        self.route = other
    }

    var id: UUID {
        route.id
    }

}

extension AnyRoute: Equatable {

    static func == (lhs: AnyRoute, rhs: AnyRoute) -> Bool {
        lhs.equals(other: rhs)
    }

}

struct Root: Route {

    let id: UUID = UUID()

}

struct Push: Route {

    let id: UUID = UUID()

}

protocol Routeable {

    associatedtype Model: Hashable

}

protocol Screen: View, Routeable {

    init(model: Model)
    func ok()

}

extension Screen where Self: View {

    func ok() {

    }

}

protocol Router: View {

}

struct NavigationRouter<S>: Router where S: Screen {

    @Environment(\.routingTree) var routingTree
    @Environment(\.currentRoute) var currentRoute

    private var path: NavigationPath { makePath() }
    private var content: S

    var body: some View {
        NavigationStack(
            root: { content }
        )
    }

    init(content: () -> S) {
        self.content = content()
    }

    private func makePath() -> NavigationPath {

        thisRoute.children.reduce(NavigationPath(), { path, element in
            path.append(0)

            return
        })

        return thisRoute.children.reduce(NavigationPath(), { accumulator, element in
            guard let onlyChild = element.children.first, element.children.count == 1 else {
                fatalError("Navigation hierarchy corrupted")
            }

            accumulator.append(onlyChild.value)
        })
    }

}

struct TabRouter: Router {

    var body: some View {
        EmptyView()
    }

}

struct SimpleRouter<S>: Router where S: Screen {

    private let content: S

    var body: some View {
        content
    }

    init(content: () -> S) {
        self.content = content()
    }

}

struct AppRouter<R>: Scene where R: Router {

    private let content: R

    var body: some Scene {
        WindowGroup {
            content.environment(\.routingTree, RoutingTree.defaultValue)
        }
    }

    init(content: () -> R) {
        self.content = content()
    }

}

struct RoutingTree: EnvironmentKey {

    static var defaultValue: Node<AnyRoute> { Node(Root().eraseToAnyRoute()) }
    
}

struct CurrentRoute: EnvironmentKey {

    static var defaultValue: AnyRoute { Root().eraseToAnyRoute() }

}

extension EnvironmentValues {

    var routingTree: Tree<AnyRoute> {
        get { self[RoutingTree.self] }
        set { self[RoutingTree.self] = newValue }
    }

    var currentRoute: AnyRoute {
        get { self[CurrentRoute.self] }
        set { self[CurrentRoute.self] = newValue }
    }

}
