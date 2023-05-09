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

    static var defaultValue: Node<any Route> { Node(Root()) }
    
}

//struct CurrentRoute: EnvironmentKey {
//
//    static var defaultValue: any Route { Root() }
//
//}

extension EnvironmentValues {

    var routingTree: Tree<any Route> {
        get { self[RoutingTree.self] }
        set { self[RoutingTree.self] = newValue }
    }

//    var currentRoute: any Route {
//        get { self[CurrentRoute.self] }
//        set { self[CurrentRoute.self] = newValue }
//    }

}
