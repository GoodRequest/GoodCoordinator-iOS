//
//  NavigationCoordinatorViewWrapper.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

struct NavigationCoordinatorViewWrapper<T: NavigationCoordinator>: ViewModifier {

    var coordinator: T

    private let id: Int // TODO: get rid of IDs
    private let router: NavigationRouter<T>

    @ObservedObject var presentationHelper: NavigationCoordinatorHelper<T>

    // MARK: - Initialization

    init(id: Int, coordinator: T) {
        self.id = id
        self.coordinator = coordinator

        self.presentationHelper = NavigationCoordinatorHelper(
            id: id,
            coordinator: coordinator
        )

        self.router = NavigationRouter(
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
        Color.clear.overlay { current }.navigationDestination(
            isPresented: presentationBinding(),
            destination: destination
        )
    }

    @ViewBuilder private func navigatableContent_old(current: Content) -> some View {
        Color.clear.overlay { current }.background {
            NavigationLink(
                destination: destination(),
                isActive: presentationBinding(),
                label: { EmptyView() }
            ).hidden()
        }
    }

    @ViewBuilder private func destination() -> some View {
        if let view = presentationHelper.presented {
            AnyView(view)
        } else {
            EmptyView()
        }
    }

    // MARK: - Bindings

    private func presentationBinding() -> Binding<Bool> {
        Binding<Bool>(get: {
            presentationHelper.presented != nil
        }, set: {
            guard !$0 else { return }
            coordinator.popTo(id)
        })
    }

}
