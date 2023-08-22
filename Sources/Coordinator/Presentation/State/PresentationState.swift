//
//  PresentationState.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 31/07/2023.
//

import SwiftUI

// MARK: - Presentation state

public class PresentationState: ObservableObject {

    internal weak var parent: (any Coordinator)?

    internal var root: RootItem {
        didSet {
            print("New root set to \(address(of: root))")
        }
    }

    @Published private(set) internal var presented: [PresentationItem<Any>] = [] { // covariant
        willSet {
            print("Will set on: \(address(of: self))")
        }
        didSet {
            print("Presentation state: \(oldValue.count == 1) -> \(presented.count == 1)")
        }
    }

    public init() {
        self.root = RootItem(screen: EmptyView())
        print("+ init \(address(of: self))")
    }

    deinit {
        print("- deinit \(address(of: self))")
    }

}

// MARK: - Presentation functions

internal extension PresentationState {

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

internal extension PresentationState {

    func canDismissChild() -> Bool {
        presented.count == 1
    }

    func isPresenting() -> Bool {
        canDismissChild()
    }

}
