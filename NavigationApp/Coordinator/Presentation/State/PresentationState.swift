//
//  PresentationState.swift
//  NavigationApp
//
//  Created by Filip Šašala on 31/07/2023.
//

import SwiftUI

// MARK: - Presentation state

class PresentationState: ObservableObject {

    var parent: (any Coordinator)?

    @Published var root: RootItem

    @Published private(set) var presented: [PresentationItem<Any>] = [] { // covariant
        willSet {
            print("Will set on: \(address(of: self))")
        }
        didSet {
            print("Presentation state: \(oldValue.count == 1) -> \(presented.count == 1)")
        }
    }

    init() {
        self.root = RootItem(screen: EmptyView())
        print("+ init \(address(of: self))")
    }

    deinit {
        print("- deinit \(address(of: self))")
    }

}

// MARK: - Presentation functions

extension PresentationState {

    func present(_ item: PresentationItem<Any>) {
        guard presented.count < 1 else { preconditionFailure("Presenting multiple windows is not supported") }
        presented.append(item)
    }

    func dismissChild() {
        guard presented.count <= 1 else { preconditionFailure("Presenting multiple windows is not supported") }
        presented = []
    }

}

// MARK: - Helper functions

extension PresentationState {

    func canDismissChild() -> Bool {
        presented.count == 1
    }

    func isPresenting() -> Bool {
        canDismissChild()
    }

}
