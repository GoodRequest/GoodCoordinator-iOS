//
//  NavigationApp.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI

// MARK: - main

@main struct NavigationApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            SwiftUI.NavigationStack {
                coordinator.body
            }
        }
    }

}

final class AppCoordinator: NavigationCoordinator {

    // var stack: Stinsen.NavigationStack<AppCoordinator> = .init(initial: \.root)
    var stack: NavigationStack<AppCoordinator> = .init(initial: \.root)

    @RootRoute var root = makeRoot
    @PresentRoute var home = makeHome

//    @Route var mainRoot = GRTransition<AppCoordinator, Push, Any, some View>(type: Push(), closure: { coordinator in
//        return makeRoot
//    })

    @ViewBuilder func makeRoot() -> some View {
        LoginView(model: LoginModel())
    }

    @ViewBuilder func makeHome() -> some View {
        HomeView()
    }

}
