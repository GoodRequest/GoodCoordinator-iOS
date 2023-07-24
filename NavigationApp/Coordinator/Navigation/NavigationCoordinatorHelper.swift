//
//  NavigationCoordinatorHelper.swift
//  NavigationApp
//
//  Created by Filip Šašala on 09/05/2023.
//

import SwiftUI
import Combine

final class NavigationCoordinatorHelper<T: NavigationCoordinator>: ObservableObject {

    private let id: Int
    let navigationStack: NavigationStack; #warning("Memory leak?")
    var cancellables = Set<AnyCancellable>()

    @Published var child: (any Screen)?

    init(id: Int, coordinator: T) {
        self.id = id
        self.navigationStack = coordinator.state

        self.setupChild(coordinator: coordinator)

        navigationStack.$items
            .scan(([], [])) { ($0.1, $1) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] previous, current in
                guard let self else { return }
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
            setupChild(coordinator: coordinator)
        } else {
            #warning("TODO: pop only once if possible")
//
//            let isTopScreen = (self.child == nil) && (navigationStack.items.count - 1 == (id + 1))
//            guard isTopScreen else { return }

            let popDestination = (current.count - 1)
            popChild(to: popDestination)
        }
    }

    func popChild(to destination: Int) {
        if id >= destination {
            child = nil
        }
    }

    func setupChild(coordinator: T) {
        let nextId = id + 1
        let isTopScreen = (self.child == nil) && (navigationStack.items.count - 1 == nextId)

        // Only apply changes on last screen in navigation stack
        guard isTopScreen else { return }
        self.child = coordinator.state.screenWithId(nextId).modifier(NavigationCoordinatorViewWrapper(
            id: nextId,
            coordinator: coordinator
        ))
    }

}

/*
 var current: some View {
 Color.clear.overlay { AnyView(coordinator.state.screenWithId(id)) }
 }
 */
