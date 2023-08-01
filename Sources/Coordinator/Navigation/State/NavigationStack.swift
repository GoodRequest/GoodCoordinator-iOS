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

    private let title: String

    private var lastPoppedItem: (NavigationStackItem<Any>)?

    @Published private(set) internal var items: [NavigationStackItem<Any>] = [] { // covariant
        willSet {
            print("Will set on: \(title)")
        }
        didSet {
            print("Navigation stack items: \(oldValue.count) -> \(items.count)")
        }
    }

    public init(debugTitle: String) {
        print("+ init \(debugTitle)")
        self.title = debugTitle

        super.init()
    }

    deinit {
        print("- deinit \(title)")
    }

    internal func screenAtIndex(_ index: Int) -> Screen {
        if index < Self.rootIndex {
            let _ = assertionFailure("Invalid screen index!")
            return EmptyView()
        } else if index == Self.rootIndex {
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
            return assertionFailure("Already at root. Use `abortChild()` instead.")
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
