//
//  NavigationApp.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI

protocol NavigationError: Error {

    var description: String { get }

}

final class NavigationObject: ObservableObject {

    @Published var navigationPath: NavigationPath = .init()

    func pop() {
        navigationPath.removeLast()
    }

    func set(_ newPath: NavigationPath) {
        navigationPath.removeLast(navigationPath.count)
        navigationPath = newPath
    }

}

enum AvailableContexts: Context, CaseIterable {

    case login
    case home

    var id: String {
        switch self {
        case .login:
            return "login"

        case .home:
            return "home"
        }
    }

    var content: some View {
        switch self {
        case .login:
            return AnyView(LoginView())

        case .home:
            return AnyView(HomeView())
        }
    }

}

@main struct NavigationApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var navigationObject = NavigationObject()

    var body: some Scene {
        AppContext(allAvailable: AvailableContexts.allCases)
    }

    /*
    func content() -> some View {
        NavigationStack(
            path: $navigationObject.navigationPath,
            root: {
                EmptyView()
                    .navigationDestination(for: LoginModel.self, destination: { model in
                        LoginView()
                            .environmentObject(navigationObject)
                    })
                    .navigationDestination(for: RegistrationModel.self, destination: { model in
                        RegistrationView(model: model)
                            .environmentObject(navigationObject)
                    })
                    .navigationDestination(for: HomeModel.self, destination: { model in
                        HomeView()
                            .environmentObject(navigationObject)
                    })
                    .environmentObject(navigationObject)
            }
        )
        .onChange(of: navigationObject.navigationPath, perform: { path in
            print("Current path: \(path)")
        })
    }*/

}
