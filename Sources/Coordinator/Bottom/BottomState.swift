//
//  BottomState.swift
//  
//
//  Created by Filip Šašala on 01/08/2023.
//

import SwiftUI

public final class BottomState: ObservableObject {

    internal weak var parent: (any Coordinator)?

    @Published internal var root: RootItem

    public init() {
        self.root = RootItem(screen: EmptyView())
    }

}
