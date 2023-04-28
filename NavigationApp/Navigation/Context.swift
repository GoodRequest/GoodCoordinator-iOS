//
//  Context.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI

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

struct Path {

}

final class AppRouter: ObservableObject {

    @Published private var currentRoute: String = ""

    var path: [Path] = []

}

struct AppRouterScene: Scene {

    @StateObject private var appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            Text("Sample router")
        }
    }

}
