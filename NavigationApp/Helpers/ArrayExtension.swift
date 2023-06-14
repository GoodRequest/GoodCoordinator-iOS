//
//  ArrayExtension.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import Foundation

@resultBuilder public struct ArrayBuilder<Element> {

    public static func buildPartialBlock(first: Element) -> [Element] {
        [first]
    }

    public static func buildPartialBlock(first: [Element]) -> [Element] {
        first
    }

    public static func buildPartialBlock(accumulated: [Element], next: Element) -> [Element] {
        accumulated + [next]
    }

    public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] {
        accumulated + next
    }

    /// Empty
    public static func buildBlock() -> [Element] {
        []
    }

    /// If/Else
    public static func buildEither(first: [Element]) -> [Element] {
        first
    }

    public static func buildEither(second: [Element]) -> [Element] {
        second
    }

    /// If
    public static func buildIf(_ element: [Element]?) -> [Element] {
        element ?? []
    }

    /// fatalError()
    public static func buildPartialBlock(first: Never) -> [Element] {}

}

public extension Array {

    init(@ArrayBuilder<Element> builder: () -> [Element]) {
        self.init(builder())
    }

    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }

}
