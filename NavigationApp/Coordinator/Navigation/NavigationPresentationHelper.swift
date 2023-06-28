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
    let navigationStack: NavigationStack<T, T.Input>; #warning("Memory leak?")
    var cancellables = Set<AnyCancellable>()

    @Published var presented: (any Screen)?

    init(id: Int, coordinator: T) {
        self.id = id
        self.navigationStack = coordinator.state

        self.setupPresented(coordinator: coordinator)

        navigationStack.$items
            .scan(([], [])) { ($0.1, $1) }
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak coordinator] previous, current in
                guard let self, let coordinator else { return }
                print("Items changed - \(previous.count) => \(current.count)")
                onItemsChanged(coordinator: coordinator, previous: previous, current: current)
            }
            .store(in: &cancellables)

        navigationStack.$root
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func onItemsChanged(coordinator: T, previous: [Any], current: [Any]) {
        if current.count > previous.count {
            setupPresented(coordinator: coordinator)
        } else {
            let popDestination = (current.count - 1)
            popPresented(to: popDestination)
        }
    }

    func popPresented(to destination: Int) {
        if id >= destination {
            print("Setting presented = nil @ \(id)")
            presented = nil
        }
    }

    func setupPresented(coordinator: T) {
        let nextId = id + 1
        let isTopScreen = (self.presented == nil) && (navigationStack.items.count - 1 == nextId)

        // Only apply changes on last screen in navigation stack
        guard isTopScreen else { return }
        self.presented = NavigationCoordinatorViewWrapper(id: nextId, coordinator: coordinator)
    }

}
