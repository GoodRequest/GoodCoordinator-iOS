//
//  NavigationRouter.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 12/09/2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct NavigationRouter: ExpressionMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        return ExprSyntax("__global_rootNavigationPath()")
    }

}
