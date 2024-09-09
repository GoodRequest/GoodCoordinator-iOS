//
//  MacroCollection.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 07/09/2024.
//

import Foundation
import SwiftCompilerPlugin
@_spi(ExperimentalLanguageFeature) import SwiftSyntaxMacros

@main struct MacroCollection: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        Navigable.self,
        NavigationRoot.self,
        NavigationRouter.self
    ]

}
