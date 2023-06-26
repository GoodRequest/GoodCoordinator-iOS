//
//  Coordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import Foundation

protocol Coordinator: ObservableObject { // , ChildDismissable {

//    var parent: ChildDismissable? { get set }

    associatedtype State
    associatedtype Input

    init(_ input: Input)

    var parent: (any Coordinator)? { get set }
    var state: State { get set }

    func setRoot(state: inout State, to: any Screen)

}

extension Coordinator where Input == Void {

//
//    var id: String {
//        return ObjectIdentifier(self).debugDescription // TODO: betterify
//    }

}

protocol StringIdentifiable: Identifiable<String> {}

//protocol ChildDismissable: AnyObject {
//    func dismissChild<T: Coordinator>(coordinator: T, action: (() -> Void)?)
//}
