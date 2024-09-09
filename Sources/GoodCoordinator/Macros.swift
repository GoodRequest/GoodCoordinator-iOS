//
//  Macros.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 07/09/2024.
//

import Foundation

@attached(extension, conformances: DestinationCaseNavigable)
@attached(peer, names: arbitrary)
public macro Navigable() = #externalMacro(module: "GoodCoordinatorMacros", type: "Navigable")

@attached(member, names: named(__navigationPath))
@attached(peer, names: named(__global_rootNavigationPath))
public macro NavigationRoot() = #externalMacro(module: "GoodCoordinatorMacros", type: "NavigationRoot")

@freestanding(expression)
public macro router() -> Router = #externalMacro(module: "GoodCoordinatorMacros", type: "NavigationRouter")
