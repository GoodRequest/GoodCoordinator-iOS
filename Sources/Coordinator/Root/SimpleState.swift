//
//  SimpleState.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 01/08/2023.
//

import SwiftUI

public final class SimpleState: ObservableObject {

    internal weak var parent: (any Coordinator)?

    internal var root: RootItem

    public init() {
        self.root = RootItem(screen: EmptyView())
    }

}
