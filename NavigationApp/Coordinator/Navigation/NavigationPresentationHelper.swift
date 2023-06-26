//
//  Route.swift
//  NavigationApp
//
//  Created by Filip Šašala on 09/05/2023.
//

import SwiftUI
import Combine

final class NavigationPresentationHelper<T: NavigationCoordinator>: ObservableObject {

    private let id: Int
    let navigationStack: NavigationStack<T, T.Input>; #warning("Memory leak")
    var cancellables = Set<AnyCancellable>()

    @Published var presented: (any Screen)?

    init(id: Int, coordinator: T) {
        self.id = id
        self.navigationStack = coordinator.state

        self.setupPresented(coordinator: coordinator)

        navigationStack.$items
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak coordinator] _ in
                guard let self, let coordinator else { return }
                setupPresented(coordinator: coordinator)
            }
            .store(in: &cancellables)

        navigationStack.$root
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak coordinator] in
            }

//        navigationStack.poppedTo.filter { int -> Bool in int <= id }.sink { [weak self] int in
//            print(int, id)
//            DispatchQueue.main.async { [weak self] in
//                self?.presented = nil
//            }
//        }
//        .store(in: &cancellables)
    }

    func setupPresented(coordinator: T) {
        let stackItems = self.navigationStack.items

        let nextId = id + 1

        // Only apply updates on last screen in navigation stack
        // This check is important to get the behaviour as using a bool-state in the view that you set
        if stackItems.count - 1 == nextId, self.presented == nil {
            if let value = stackItems[safe: nextId] {
                let presentable = value.screen

                let view = NavigationCoordinatorViewWrapper(id: nextId, coordinator: coordinator)
                self.presented = AnyView(view)
//                self.presented = AnyView(
//                    NavigationView(
//                        content: {
//                            view.navigationBarHidden(true)
//                        }
//                    )
//                    .navigationViewStyle(StackNavigationViewStyle())
//                    SwiftUI.NavigationStack { view }
//                )
            }
        }
    }

}
