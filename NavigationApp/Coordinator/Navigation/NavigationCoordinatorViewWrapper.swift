//
//  NavigationCoordinatorViewWrapper.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

struct NavigationCoordinatorViewWrapper<T: NavigationCoordinator>: View {

    var coordinator: T
    var content: any Screen

    private let id: Int // TODO: get rid of IDs
    private let router: NavigationRouter<T>

    @ObservedObject var presentationHelper: NavigationPresentationHelper<T>

    // MARK: - Initialization

    init(id: Int, coordinator: T) {
        self.id = id
        self.coordinator = coordinator

        self.presentationHelper = NavigationPresentationHelper(
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

        // RouterStore.shared.store(router: router)

        if let stackItem = coordinator.stack.value[safe: id] {
            self.content = stackItem.screen
        } else if id == -1 {
            self.content = coordinator.stack.root.item.screen
        } else {
            print("⛔️ Pushed screen missing from coordinator stack!")
            self.content = EmptyView()
        }
    }

    // MARK: - Body

    var body: some View {
        if #available(iOS 16, *) {
            navigatableContent().environmentObject(router)
        } else {
            navigatableContent_old().environmentObject(router)
        }
    }

    // MARK: - Navigation

    @available(iOS 16, *)
    @ViewBuilder private func navigatableContent() -> some View {
        AnyView(content).navigationDestination(
            isPresented: presentationBinding(),
            destination: destination
        )
    }

    @ViewBuilder private func navigatableContent_old() -> some View {
        AnyView(content).background {
            NavigationLink(
                destination: destination(),
                isActive: presentationBinding(),
                label: { EmptyView() }
            ).hidden()
        }
    }

    @ViewBuilder private func destination() -> some View {
        if let view = presentationHelper.presented {
            AnyView(view).onDisappear {
                self.coordinator.stack.dismissalAction[id]?() // TODO: presunut inde
                self.coordinator.stack.dismissalAction[id] = nil
            }
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
