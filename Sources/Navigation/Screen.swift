//
//  Screen.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

public protocol Screen {

    func makeView() -> AnyView

}

public extension Screen where Self: View {

    func makeView() -> AnyView {
        AnyView(self)
    }

}

extension AnyView: Screen {}
extension EmptyView: Screen {}
