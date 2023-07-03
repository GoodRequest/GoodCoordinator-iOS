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
    @RootStep(makeHome) var home
    @PushStep(makeOther) var registration

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
        OtherCoordinator(())
    }

}

struct OtherCoordinator: PresentationCoordinator {

    typealias Input = Void
    var state: NavigationStack = .init()

    @RootStep(makeRoot) var root
    @PresentStep(makePresentSomething) var presentSomething

    @ViewBuilder func makeRoot() -> some Screen {
        // AnyView(Text("Input"))
        RegistrationView(model: RegistrationModel(name: "asdf"))
    }

    @ViewBuilder func makeAppCoordinator() -> some Screen {
        AppCoordinator(())
    }

    @ViewBuilder func makePresentSomething() -> some Screen {
//        AnyView(Text("Present"))
        MyCoordinator(())
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
