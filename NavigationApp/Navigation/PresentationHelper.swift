//
//  Route.swift
//  NavigationApp
//
//  Created by Filip Šašala on 09/05/2023.
//

import SwiftUI
import Combine

struct Presented {
    var view: AnyView
}

final class PresentationHelper<T: Coordinator>: ObservableObject {
    private let id: Int
    let navigationStack: NavigationStack<T>
    private var cancellables = Set<AnyCancellable>()

    @Published var presented: Presented?

    func setupPresented(coordinator: T) {
        let value = self.navigationStack.value

        let nextId = id + 1

        // Only apply updates on last screen in navigation stack
        // This check is important to get the behaviour as using a bool-state in the view that you set
        if value.count - 1 == nextId, self.presented == nil {
            if let value = value[safe: nextId] {
                let presentable = value.presentable

                let view = AnyView(CoordinatorViewWrapper(id: nextId, coordinator: coordinator))
                self.presented = Presented(
                    view: AnyView(
                        NavigationView(
                            content: {
                                view.navigationBarHidden(true)
                            }
                        )
                        .navigationViewStyle(StackNavigationViewStyle())
                    )
                )
            }
        }
    }

    init(id: Int, coordinator: T) {
        self.id = id
        self.navigationStack = coordinator.stack

        self.setupPresented(coordinator: coordinator)

        navigationStack.$value.dropFirst().sink { [weak self, coordinator] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.setupPresented(coordinator: coordinator)
            }
        }
        .store(in: &cancellables)

        navigationStack.poppedTo.filter { int -> Bool in int <= id }.sink { [weak self] int in
            // remove any and all presented views if my id is less than or equal to the view being popped to!
            DispatchQueue.main.async { [weak self] in
                self?.presented = nil
            }
        }
        .store(in: &cancellables)
    }
}
