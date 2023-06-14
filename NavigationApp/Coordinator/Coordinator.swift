//
//  Coordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import Foundation

protocol Coordinator: ObservableObject, Screen { // , ChildDismissable {

//    var parent: ChildDismissable? { get set }

    var parent: (any Coordinator)? { get set }

}

extension Coordinator {
//
//    var id: String {
//        return ObjectIdentifier(self).debugDescription // TODO: betterify
//    }

}

protocol StringIdentifiable: Identifiable<String> {}

//protocol ChildDismissable: AnyObject {
//    func dismissChild<T: Coordinator>(coordinator: T, action: (() -> Void)?)
//}
