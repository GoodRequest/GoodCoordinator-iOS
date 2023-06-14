//
//  NavigationCoordinatorViewWrapper.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

struct NavigationCoordinatorViewWrapper<T: NavigationCoordinator>: View {

    var coordinator: T
    var start: AnyView?

    private let id: Int
    private let router: NavigationRouter<T>

    @ObservedObject var presentationHelper: NavigationPresentationHelper<T>
    @ObservedObject var root: NavigationRoot

    @State var presentationActive: Bool = true

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
                if let view = presentationHelper.presented {
                    return view.onDisappear {
                        self.coordinator.stack.dismissalAction[id]?()
                        self.coordinator.stack.dismissalAction[id] = nil
                    }
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
//                isActive: $presentationActive,
                label: { EmptyView() }
            ).hidden()
        }
    }

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

        self.root = coordinator.stack.root

        // RouterStore.shared.store(router: router)

        if let presentation = coordinator.stack.value[safe: id] {
            if let view = presentation.presentable as? AnyView { // TODO: useless cast
                self.start = view
            } else {
                fatalError("Can only show views")
            }
        } else if id == -1 {
            self.start = nil
        } else {
            fatalError("???")
        }

        presentationHelper.$presented.sink { [self] in
            print("Is nil:", $0 == nil)
            presentationActive = ($0 != nil)
        }.store(in: &presentationHelper.cancellables)
    }

}
