//
//  PresentationCoordinatorViewWrapper.swift
//  NavigationApp
//
//  Created by Filip Šašala on 03/07/2023.
//

import SwiftUI

struct PresentationCoordinatorViewWrapper<T: PresentationCoordinator>: Screen {

    var coordinator: T
    var current: some View {
        Color.clear.overlay { AnyView(coordinator.state.root.screen) }
    }

    private let router: PresentationRouter<T>

    @ObservedObject var presentationHelper: PresentationCoordinatorHelper<T>

    // MARK: - Initialization

    init(coordinator: T) {
        self.coordinator = coordinator

        self.router = PresentationRouter(coordinator: coordinator)
        self.presentationHelper = PresentationCoordinatorHelper(coordinator: coordinator)

        // RouterStore.shared.store(router: router)
    }

    // MARK: - Body

    var body: some View {
        current.sheet(
            isPresented: presentationBinding(),
            content: presentedView
        )
        .environmentObject(router)
    }

    @ViewBuilder func presentedView() -> some View {
        if let presented = coordinator.state.presented.first?.screen {
            AnyView(presented)
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
            coordinator.state.dismiss()
        })
    }

}
