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
            coordinator
        }
    }

}

struct AppCoordinator: NavigationCoordinator {

    typealias Input = Void
    var state: NavigationStack = .init()

    @RootStep(makeRoot) var root
    @RootStep(makeHome) var `switch`
    @PushStep(makeHome) var push
    @PresentStep(makeOther) var present

    @ViewBuilder func makeRoot() -> some Screen {
        LoginView(model: LoginModel())
    }

    @ViewBuilder func makeHome() -> some Screen {
        HomeView()
    }

    @ViewBuilder func makeOther() -> some Screen {
        OtherCoordinator("Janko Hraško")
    }

}

struct OtherCoordinator: PresentationCoordinator {

    typealias Input = String
    var state: NavigationStack = .init()

    @RootStep(makeRoot) var root
    @PresentStep(makePresentSomething) var presentSomething

    @ViewBuilder func makeRoot(name: String) -> some Screen {
        // AnyView(Text("Input"))
        RegistrationView(model: RegistrationModel(name: name))
    }

    @ViewBuilder func makeAppCoordinator() -> some Screen {
        AppCoordinator(())
    }

    @ViewBuilder func makePresentSomething() -> some Screen {
        AppCoordinator(())
    }

}

struct MyCoordinator: NavigationCoordinator {

    typealias Input = Void
    var state: NavigationStack = .init()

   @RootStep(makeRootView) var root

    @ViewBuilder func makeRootView() -> some Screen {
        AnyView(Text("My root view").navigationTitle("Modal"))
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
