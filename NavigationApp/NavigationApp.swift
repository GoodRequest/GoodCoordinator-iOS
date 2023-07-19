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

    @ViewBuilder func makeRoot() -> LoginView {
        LoginView(model: LoginModel())
    }

    @ViewBuilder func makeHome() -> HomeView {
        HomeView()
    }

    @ViewBuilder func makeOther(action: @escaping VoidClosure) -> OtherCoordinator {
        OtherCoordinator(action)
    }

}

struct OtherCoordinator: PresentationCoordinator {

    typealias Input = VoidClosure
    var state: NavigationStack = .init()

    @RootStep(makeRoot) var root
    @PresentStep(makePresentSomething) var presentSomething

    @ViewBuilder func makeRoot(name: @escaping VoidClosure) -> AnyView {
        AnyView(RegistrationView(model: RegistrationModel(name: "Name")).onDisappear {
            name()
        })
    }

    @ViewBuilder func makeAppCoordinator() -> AppCoordinator {
        AppCoordinator(())
    }

    @ViewBuilder func makePresentSomething() -> AppCoordinator {
        AppCoordinator(())
    }

}

struct MyCoordinator: NavigationCoordinator {

    typealias Input = Void
    var state: NavigationStack = .init()

    @RootStep(makeRoot) var root

    @ViewBuilder func makeRoot() -> AnyView {
        AnyView(Text("asdf my coordinator"))
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
