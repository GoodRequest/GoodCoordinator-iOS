//
//  PresentationItem.swift
//  NavigationApp
//
//  Created by Filip Šašala on 31/07/2023.
//

struct PresentationItem<Input> {

    let input: Input
    let style: PresentationStyle

    var screen: any Screen // child?
    var dismissAction: VoidClosure? = nil

}
