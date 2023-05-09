//
//  Route.swift
//  NavigationApp
//
//  Created by Filip Šašala on 09/05/2023.
//

import SwiftUI

protocol Route: Hashable, Identifiable {}

extension Route {

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}

struct Root: Route {

    let id: UUID = UUID()

}

struct Push<Content: Screen>: Route {

    let screen: Content

    var id: Content.ID {
        screen.id
    }

}
