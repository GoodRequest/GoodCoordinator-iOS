//
//  NavigationStack.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 31/07/2023.
//

import SwiftUI

// MARK: - Navigation stack

public class NavigationStack: PresentationState {

    internal static let rootIndex = -1

    private var lastPoppedItem: (NavigationStackItem<Any>)?

    @Published private(set) internal var items: [NavigationStackItem<Any>] = [] { // covariant
        willSet {
            print("Will set on: \(address(of: self))")
        }
        didSet {
            print("Navigation stack items: \(oldValue.count) -> \(items.count)")
        }
    }

    internal func screenAtIndex(_ index: Int) -> Screen {
        if index < NavigationStack.rootIndex {
            let _ = assertionFailure("Invalid screen index!")
            return EmptyView()
        } else if index == NavigationStack.rootIndex {
            return root.screen
        } else {
            let screen = items[safe: index]?.screen ?? lastPoppedItem?.screen ?? EmptyView()
            return screen
        }
    }

}

// MARK: - Navigation functions

internal extension NavigationStack {

    func push(items newItems: [NavigationStackItem<Any>]) {
        items.append(contentsOf: newItems)
    }

    func pop(to id: Int) {
        let popIndex = id + 1
        if id == Self.rootIndex && items.isEmpty {
            return // Already at root, do nothing
        }
        guard items.startIndex..<items.endIndex ~= popIndex else {
            return assertionFailure("Invalid index. Use `abortChild()` instead.")
        }

        let rangeToPop = popIndex..<items.endIndex
        let itemsToPop = items[rangeToPop]
        lastPoppedItem = itemsToPop.first

        items.remove(atOffsets: IndexSet(integersIn: rangeToPop))
        itemsToPop.reversed().forEach { $0.dismissAction?() }
    }

    func revert() {
        guard let lastPoppedItem else { return }
        items.append(lastPoppedItem)
        self.lastPoppedItem = nil
    }

}

// MARK: - Helper functions

internal extension NavigationStack {

    func isValidIndex(_ index: Int) -> Bool {
        Self.rootIndex..<(items.endIndex - 1) ~= index
    }

    func top() -> NavigationStackItem<Any>? {
        items.last
    }

}
