//
//  NavigationCoordinatorViewWrapper.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

internal struct NavigationCoordinatorViewWrapper<T: NavigationCoordinator>: ViewModifier {

    let coordinator: T
    private let router: Router<T>
    private let id: Int // TODO: get rid of IDs

    @ObservedObject var navigationHelper: NavigationCoordinatorHelper<T>

    // MARK: - Initialization

    init(id: Int, coordinator: T) {
        self.id = id
        self.coordinator = coordinator

        self.navigationHelper = NavigationCoordinatorHelper(
            id: id,
            coordinator: coordinator
        )

        self.router = Router(
            coordinator: coordinator
        )

        // RouterStore.shared.store(router: router)
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            navigatableContent(current: content).environmentObject(router)
        } else {
            navigatableContent_old(current: content).environmentObject(router)
        }
    }

    // MARK: - Navigation

    @available(iOS 16, *)
    @ViewBuilder private func navigatableContent(current: Content) -> some View {
        current.navigationDestination(
            isPresented: presentationBinding(),
            destination: destination
        )
    }

    @ViewBuilder private func navigatableContent_old(current: Content) -> some View {
        current.background(
            NavigationLink(
                destination: destination(),
                isActive: presentationBinding(),
                label: { EmptyView() }
            ).hidden()
        )
    }

    @ViewBuilder private func destination() -> some View {
        if let view = navigationHelper.nextChild {
            AnyView(view)
        } else {
            EmptyView()
        }
    }

    // MARK: - Bindings

    private func presentationBinding() -> Binding<Bool> {
        Binding<Bool>(get: {
            navigationHelper.nextChild != nil
        }, set: {
            /// Check that the binding is being set to false and is valid
            guard !$0 && coordinator.canPopToScreen(with: id) else { return }
            coordinator.popTo(id)
        })
    }

}
