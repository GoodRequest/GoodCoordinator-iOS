//
//  Coordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import SwiftUI

protocol Coordinator: Screen { // , ChildDismissable {

//    var parent: ChildDismissable? { get set }

    associatedtype State
    associatedtype Input

    init(_ input: Input)

    var parent: (any Coordinator)? { get set }
    var state: State { get set }

    func setRoot(to: any Screen)

}

protocol StringIdentifiable: Identifiable<String> {}

//protocol ChildDismissable: AnyObject {
//    func dismissChild<T: Coordinator>(coordinator: T, action: (() -> Void)?)
//}
