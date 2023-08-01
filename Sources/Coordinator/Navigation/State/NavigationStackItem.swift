//
//  NavigationStackItem.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 31/07/2023.
//

public struct NavigationStackItem<Input> {

    let input: Input
    var screen: any Screen // child?
    var dismissAction: VoidClosure? = nil

}
