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
            if #available(iOS 16, *) {
                SwiftUI.NavigationStack {
                    coordinator.body
                }
            } else {
                SwiftUI.NavigationView {
                    coordinator.body
                }.navigationViewStyle(.stack)
            }
        }
    }

}

final class AppCoordinator: NavigationCoordinator {

    var stack: NavigationStack<AppCoordinator> = .init(initial: \.root)

    @RootRoute var root = makeRoot
    @PresentRoute var home = makeHome
    @PresentRoute var uiKit = makeUiKit

    @ViewBuilder func makeRoot() -> some View {
        LoginView(model: LoginModel())
    }

    @ViewBuilder func makeHome() -> some View {
        HomeView()
    }

    @ViewBuilder func makeUiKit() -> some View {
        CollectionViewRepresentable()
    }

}

struct CollectionViewRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> some UIViewController {
        return UICollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        print("hello world")
    }

}
