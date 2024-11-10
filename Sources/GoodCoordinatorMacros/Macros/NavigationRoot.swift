//
//  NavigationRoot.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 11/09/2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct NavigationRoot: MemberMacro, PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let navigationPathDeclSyntax = DeclSyntax("@MainActor static let __navigationPath: Router = Router()")

        return [navigationPathDeclSyntax]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let navigationRootDeclarationName = declaration.as(StructDeclSyntax.self)?.name.text else {
            throw NavigationRootMacroError.notAViewStruct
        }

        let funcBody = "return \(navigationRootDeclarationName).__navigationPath"
        let navigationRootSyntax = DeclSyntax("@MainActor internal func __module_rootNavigationPath() -> Router { \(raw: funcBody) }")


        return [navigationRootSyntax]
    }

}

enum NavigationRootMacroError: Error, CustomStringConvertible {

    case notAViewStruct

    var description: String {
        switch self {
        case .notAViewStruct:
            "NavigationRoot macro can only be applied to a struct"
        }
    }
    
}
