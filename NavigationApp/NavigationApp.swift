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

final class AppCoordinator: PresentationCoordinator {

    typealias Input = Void
//    var state: NavigationStack = .init(debugTitle: "AppCoordinator")
    var state: PresentationState = .init()

    @Root(makeRoot) var root
    @Root(makeHome) var `switch`
    // @Push(makeOther) var push
    // @Push(makeHome) var pushHome

    @Present(makeOther) var push
    @Present(makeHome) var pushHome
    @Present(makeOther, .sheet) var present

    func makeRoot() -> LoginView {
        LoginView(model: LoginModel())
    }

    func makeHome() -> MyCoordinator {
        MyCoordinator(())
    }

    func makeOther() -> OtherCoordinator {
        OtherCoordinator("Sample text")
    }

}

final class OtherCoordinator: NavigationCoordinator {

    typealias Input = String
    var state: NavigationStack = .init(debugTitle: "OtherCoordinator")

    @Root(makeRoot) var root
    @Push(makeMine) var push
    @Push(makeAppCoordinator) var pushSample
    @Present(makeAppCoordinator, .sheet) var present

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
    var state: NavigationStack = .init(debugTitle: "MyCoordinator")

    @Root(makeRoot) var root

    func makeRoot() -> HomeView {
        // AnyView(Text("asdf my coordinator"))
        HomeView()
    }

    @Present(makeOther) var push
    
    func makeOther() -> OtherCoordinator {
        OtherCoordinator("Sample text")
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
