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
    var state: NavigationStack = .init(string: "AppCoordinator")

    @RootStep(makeRoot) var root
    @RootStep(makeHome) var `switch`
    @PushStep(makeOther) var push
    @PushStep(makeHome) var pushHome
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
    var state: NavigationStack = .init(string: "OtherCoordinator")

    @RootStep(makeRoot) var root
    @PushStep(makeMine) var push
    @PushStep(makeAppCoordinator) var pushSample
    @PresentStep(makeAppCoordinator, .sheet) var present

    func makeRoot(name: String) -> RegistrationView {
        RegistrationView(model: RegistrationModel(name: name))
    }

    func makeSampleScreen() -> AnyView {
        AnyView(Text("Dobry vecer 3"))
    }

    func makeAppCoordinator() -> AppCoordinator {
        AppCoordinator(())
    }

    func makeMine() -> MyCoordinator {
        MyCoordinator(())
    }

}

final class MyCoordinator: NavigationCoordinator {

    typealias Input = Void
    var state: NavigationStack = .init(string: "MyCoordinator")

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

    func makeView() -> Never {
        preconditionFailure()
    }

}
