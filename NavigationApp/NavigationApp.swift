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

    private let coordinator = AppCoordinator(())

    var body: some Scene {
        WindowGroup {
            coordinator.body
        }
    }

}

final class AppCoordinator: NavigationCoordinator {

    typealias Input = Void
    @Published var state: NavigationStack<AppCoordinator, Void> = .init()

    @RootStep(makeRoot) var root
    @RootStep(makeHome) var homeRoot
    @PushStep(makeHome) var homePush

//    @PresentRoute var uiKit = makeUiKit

    @ViewBuilder func makeRoot() -> some Screen {
        AnyView(LoginView(model: LoginModel()).onAppear {
            // print("Input: \(input)")
            print("No params")
        })
    }

    @ViewBuilder func makeHome() -> some Screen {
        // HomeView()
        AnyView(OtherCoordinator().body)
    }

    @ViewBuilder func makeUiKit() -> some Screen {
        CollectionViewRepresentable()
    }

}

final class OtherCoordinator: NavigationCoordinator {

    typealias Input = Void
    var state: NavigationStack<OtherCoordinator, Void> = .init()

    @RootStep(makeRoot) var root

    @ViewBuilder func makeRoot() -> some Screen {
        AnyView(Text("Text!"))
    }

}

struct CollectionViewRepresentable: UIViewControllerRepresentable, Screen {

    func makeUIViewController(context: Context) -> some UIViewController {
        return UICollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        print("hello world")
    }

}
