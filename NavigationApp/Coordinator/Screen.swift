//
//  Screen.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

protocol Screen {

    associatedtype Body: View
    @ViewBuilder var body: Body { get }

}

extension Screen {

    func makeView() -> AnyView {
        AnyView(body)
    }

}

extension AnyView: Screen {

    var body: Never {
        fatalError("This property is never accessed")
    }

}
extension EmptyView: Screen {

    var body: Never {
        fatalError("This property is never accessed")
    }

}
