//
//  PresentationCoordinatorViewWrapper.swift
//  NavigationApp
//
//  Created by Filip Šašala on 03/07/2023.
//

import SwiftUI

struct PresentationCoordinatorViewWrapper<T: PresentationCoordinator>: ViewModifier {

    var coordinator: T
    private let router: Router<T>

    @ObservedObject var presentationHelper: PresentationCoordinatorHelper<T>

    // MARK: - Initialization

    init(coordinator: T) {
        self.coordinator = coordinator

        self.router = Router(coordinator: coordinator)
        self.presentationHelper = PresentationCoordinatorHelper(coordinator: coordinator)

        // RouterStore.shared.store(router: router)
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        content.sheet(
            isPresented: presentationBinding(style: .sheet),
            content: presentedView
        )
        .fullScreenCover(
            isPresented: presentationBinding(style: .fullScreenCover),
            content: presentedView
        )
        .popover(
            isPresented: presentationBinding(style: .popover),
            content: presentedView
        )
        .environmentObject(router)
    }

    @ViewBuilder func presentedView() -> some View {
        if let presented = presentationHelper.presented.first?.screen {
            AnyView(presented)
        } else {
            EmptyView()
        }
    }

    // MARK: - Bindings

    private func presentationBinding(style: PresentationStyle?) -> Binding<Bool> {
        guard style == presentationHelper.presented.first?.style else { return .constant(false) }

        return Binding<Bool>(get: {
            !presentationHelper.presented.isEmpty
        }, set: {
            guard !$0 else { return }
            coordinator.state.dismiss()
        })
    }

}

/*
 var current: some View {
 Color.clear.overlay { AnyView(coordinator.state.root.screen) }
 }
 */
