//
//  PresentationCoordinatorHelper.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 03/07/2023.
//

import SwiftUI
import Combine

internal final class PresentationCoordinatorHelper<T: PresentationCoordinator>: ObservableObject {

    let presentationState: PresentationState; #warning("Memory leak?")
    var cancellables = Set<AnyCancellable>()

    @Published var presented: [PresentationItem<Any>] = [] // covariant

    init(coordinator: T) {
        self.presentationState = coordinator.state

        presentationState.$presented
            .scan(([], [])) { ($0.1, $1) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] previous, current in
                guard let self else { return }
                onItemsChanged(coordinator: coordinator, previous: previous, current: current)
            }
            .store(in: &cancellables)

        presentationState.$root
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func onItemsChanged(coordinator: T, previous: [Any], current: [Any]) {
        if current.count > previous.count {
            presented = [coordinator.state.presented.first].compactMap { $0 }
        } else {
            presented = []
        }
    }

}
