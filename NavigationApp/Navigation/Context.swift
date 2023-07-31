//
//  Context.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI
import Combine

// MARK: - Navigation stack

class NavigationStack: PresentationState {

    @Published private(set) var items: [NavigationStackItem<Any>] = []  { // covariant
        willSet {
            print("Will set on: \(title)")
        }
        didSet {
            print("Navigation stack items: \(oldValue.count) -> \(items.count)")
        }
    }
    private var lastPoppedItem: (NavigationStackItem<Any>)?

    func screenWithId(_ id: Int) -> Screen {
        if id < -1 {
            let _ = assertionFailure("Invalid screen index!")
            return EmptyView()
        } else if id == -1 {
            return root.screen
        } else {
            let screen = items[safe: id]?.screen ?? lastPoppedItem?.screen ?? EmptyView()
            return screen
        }
    }

    let title: String
    init(string: String) {
        print("+ init \(string)")
        self.title = string

        super.init()
    }

}

// MARK: - Navigation

extension NavigationStack {

    func push(items newItems: [NavigationStackItem<Any>]) {
        items.append(contentsOf: newItems)
    }

    func pop(to id: Int) {
        let popIndex = id + 1
        if id == -1 && items.isEmpty {
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

extension NavigationStack {

    func isValidIndex(id: Int) -> Bool {
        -1..<(items.endIndex - 1) ~= id
    }

    func top() -> NavigationStackItem<Any>? {
        items.last
    }

}

// MARK: - Navigation stack items

struct CoordinatorRootItem {

    let screen: any Screen

}

struct NavigationStackItem<Input> {

    let input: Input
    var screen: any Screen // child?
    var dismissAction: VoidClosure? = nil

}
