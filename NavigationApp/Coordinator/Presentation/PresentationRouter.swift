//
//  PresentationRouter.swift
//  NavigationApp
//
//  Created by Filip Šašala on 03/07/2023.
//

import Foundation

final class PresentationRouter<T>: Routable {

    var coordinator: T

    init(coordinator: T) {
        self.coordinator = coordinator
    }
    
}
