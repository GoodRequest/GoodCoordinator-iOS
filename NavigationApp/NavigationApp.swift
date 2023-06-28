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
    @RootStep(makeHome) var home
    @PushStep(makeRegistration) var registration

//    @PresentRoute var uiKit = makeUiKit

    @ViewBuilder func makeRoot() -> some Screen {
        AnyView(LoginView(model: LoginModel()).onAppear {
            // print("Input: \(input)")
            print("No params")
        })
    }

    @ViewBuilder func makeHome() -> some Screen {
        HomeView()
    }

    @ViewBuilder func makeUiKit() -> some Screen {
        CollectionViewRepresentable()
    }

    @ViewBuilder func makeRegistration() -> some Screen {
        RegistrationView(model: RegistrationModel(name: "Jozko mrkvicka"))
    }

    @ViewBuilder func makeOther() -> some Screen {
        AnyView(OtherCoordinator(()).body.navigationTitle("Iny title"))
    }

}

final class OtherCoordinator: NavigationCoordinator {

    typealias Input = Void
    var state: NavigationStack<OtherCoordinator, Void> = .init()

    @RootStep(makeRoot) var root

    @ViewBuilder func makeRoot() -> some Screen {
        // AnyView(Text("Input"))
        RegistrationView(model: RegistrationModel(name: "asdf"))
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
