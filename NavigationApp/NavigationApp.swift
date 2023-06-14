//
//  NavigationApp.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI

/*
protocol NavigationError: Error {

    var description: String { get }

}

final class NavigationObject: ObservableObject {

    @Published var navigationPath: NavigationPath = .init()

    func pop() {
        navigationPath.removeLast()
    }

    func set(_ newPath: NavigationPath) {
        navigationPath.removeLast(navigationPath.count)
        navigationPath = newPath
    }

}

enum AvailableContexts: Context, CaseIterable {

    case login
    case home

    var id: String {
        switch self {
        case .login:
            return "login"

        case .home:
            return "home"
        }
    }

    var content: some View {
        switch self {
        case .login:
            return AnyView(LoginView())

        case .home:
            return AnyView(HomeView())
        }
    }

}
 */

// MARK: - main

@main struct NavigationApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SwiftUI.NavigationStack {
                AnyView(AppCoordinator().body)
            }
        }
    }

}

// import Stinsen

final class AppCoordinator: Coordinator {

    // var stack: Stinsen.NavigationStack<AppCoordinator> = .init(initial: \.root)
    var stack: NavigationStack<AppCoordinator> = .init(initial: \.root)

    // @Stinsen.NavigationCoordinatable.Root var root = makeRoot

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

// MARK: - Coordinator view wrapper

struct CoordinatorViewWrapper<T: Coordinator>: View {

    var coordinator: T
    var start: AnyView?

    private let id: Int
    private let router: NavigationRouter<T>

    @ObservedObject var presentationHelper: PresentationHelper<T>
    @ObservedObject var root: NavigationRoot

    var body: some View {
        content.environmentObject(router)
    }

    private var content: some View {
        let contentView: any Screen
        if id == -1 {
            contentView = root.item.child
        } else {
            contentView = self.start!
        }

        return AnyView(contentView).background {
            let destination: any View = {
                if let view = presentationHelper.presented?.view {
                    return AnyView(view.onDisappear {
                        self.coordinator.stack.dismissalAction[id]?()
                        self.coordinator.stack.dismissalAction[id] = nil
                    })
                } else {
                    return EmptyView()
                }
            }()

            NavigationLink(
                destination: AnyView(destination),
                isActive: Binding<Bool>(
                    get: {
                        presentationHelper.presented != nil
                    },
                    set: { newValue in
                        guard !newValue else { return }
                        self.coordinator.popTo(self.id, nil)

                        // self.coordinator.appear(self.id) to iste co dolu
                    }
                ),
                label: { EmptyView() }
            )
        }
    }

    init(id: Int, coordinator: T) {
        self.id = id
        self.coordinator = coordinator

        self.presentationHelper = PresentationHelper(
            id: id,
            coordinator: coordinator
        )

        self.router = NavigationRouter(
            id: id,
            coordinator: coordinator
        )

        if coordinator.stack.root == nil {
            coordinator.setupRoot()
        }

        self.root = coordinator.stack.root

        // RouterStore.shared.store(router: router)

        if let presentation = coordinator.stack.value[safe: id] {
            if let view = presentation.presentable as? AnyView {
                self.start = view
            } else {
                fatalError("Can only show views")
            }
        } else if id == -1 {
            self.start = nil
        } else {
            fatalError("???")
        }
    }

}
