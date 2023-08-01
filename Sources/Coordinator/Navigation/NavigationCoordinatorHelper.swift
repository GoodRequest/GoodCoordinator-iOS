//
//  NavigationCoordinatorHelper.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 09/05/2023.
//

import SwiftUI
import Combine

internal final class NavigationCoordinatorHelper<T: NavigationCoordinator>: ObservableObject {

    private let id: Int

    let navigationStack: NavigationStack; #warning("Memory leak?")
    let coordinator: T

    var cancellables = Set<AnyCancellable>()

    @Published var nextChild: (any View)?

    init(id: Int, coordinator: T) {
        self.id = id
        self.coordinator = coordinator
        self.navigationStack = coordinator.state

        self.setupChild()

        navigationStack.$items
            .scan(([], [])) { ($0.1, $1) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] previous, current in
                guard let self else { return }
                onItemsChanged(previous: previous, current: current)
            }
            .store(in: &cancellables)

        navigationStack.$root
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func onItemsChanged(previous: [Any], current: [Any]) {
        if current.count > previous.count {
            setupChild()
        } else {
            let popDestination = (current.count - 1)
            popChild(to: popDestination)
        }
    }

    func popChild(to destination: Int) {
        if id >= destination {
            nextChild = nil
        }
    }

    func setupChild() {
        let nextId = id + 1
        let isTopScreen = (self.nextChild == nil) && (navigationStack.items.count - 1 == nextId)

        // Only apply changes on last screen in navigation stack
        guard isTopScreen else { return }

        let child = coordinator.state.screenAtIndex(nextId)
        if child is (any Coordinator) {
            self.nextChild = child.makeView()
        } else {
            self.nextChild = child.makeView().modifier(NavigationCoordinatorViewWrapper(
                id: nextId,
                coordinator: coordinator
            ))
        }
    }

}
