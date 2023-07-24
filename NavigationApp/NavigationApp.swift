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
            coordinator.makeView()
        }
    }

}

final class AppCoordinator: NavigationCoordinator {

    typealias Input = Void
    var state: NavigationStack = .init()

    @RootStep(makeRoot) var root
    @RootStep(makeHome) var `switch`
    @PushStep(makeOther) var push
    @PresentStep(makeOther, .sheet) var present

    func makeRoot() -> LoginView {
        LoginView(model: LoginModel())
    }

    func makeHome() -> HomeView {
        HomeView()
    }

    func makeOther() -> OtherCoordinator {
        OtherCoordinator("Sample text")
    }

}

final class OtherCoordinator: NavigationCoordinator {

    typealias Input = String
    var state: NavigationStack = .init()

    @RootStep(makeRoot) var root
    @PushStep(makeRoot) var push
    @PresentStep(makeAppCoordinator, .sheet) var present

    func makeRoot(name: String) -> AnyView {
        let view: any View

        if #available(iOS 16.4, *) {
            view = RegistrationView(model: RegistrationModel(name: "Name")).makeView()
        } else {
            view = EmptyView()
        }

        return AnyView(view)
    }

    func makeAppCoordinator() -> AppCoordinator {
        AppCoordinator(())
    }

}

final class MyCoordinator: NavigationCoordinator {

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
