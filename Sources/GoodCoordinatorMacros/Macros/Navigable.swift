//
//  Navigable.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 07/09/2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct Navigable: ExtensionMacro, PeerMacro, MemberMacro {

    // MARK: - Extension macro

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let extensionDeclaration = DeclSyntax("\(declaration.attributes.availability)extension \(type.trimmed): DestinationCaseNavigable {}")
        return [extensionDeclaration.as(ExtensionDeclSyntax.self)!]
    }

    // MARK: - Member macro

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(EnumDeclSyntax.self) else {
            return [] // no diagnostic
        }

        return try CasePathableMacro.expansion(of: node, providingMembersOf: declaration, in: context)
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(EnumDeclSyntax.self) else {
            return [] // no diagnostic
        }

        return try CasePathableMacro.expansion(of: node, providingMembersOf: declaration, in: context)
    }

    // MARK: - Peer macro

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // _DestinationsActive
        guard declaration.is(EnumDeclSyntax.self) else {
            throw NavigableMacroError.notAnEnum
        }

        guard let enclosingClassDecl = context.lexicalContext.first?.as(ClassDeclSyntax.self) else {
            throw NavigableMacroError.noParentClass
        }

        let inheritedTypes = enclosingClassDecl.inheritanceClause?.inheritedTypes.compactMap {
            $0.type.as(IdentifierTypeSyntax.self)?.name.text
        } ?? []

        guard inheritedTypes.contains("Reactor") else {
            throw NavigableMacroError.outsideReactor
        }

        let attributes = enclosingClassDecl.attributes.compactMap {
            $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text
        }

        guard attributes.contains("Observable") else {
            throw NavigableMacroError.parentNotObservable
        }

        // var destination
        let observationTracked = DeclSyntax("""
        {
            get {
                defer { _modelActive = true }
                access(keyPath: \\.destination)
                if !_modelActive {
                    return #router.getOrInsert(for: self)
                } else {
                    return #router.get(for: self)
                }
            }
            set {                
                if let newValue {
                    reduce(state: &state, event: Event(destination: newValue))
                }
                
                withMutation(keyPath: \\.destination) {
                    #router.set(self, destination: newValue)
                }
            }
        }
        """)

        // Peers
        let destinationObservationDecl = DeclSyntax("var destination: Destination? \(raw: observationTracked)")
        let modelActiveVarDecl = DeclSyntax("var _modelActive: Bool = false")
        let compatibilityAccessorDecl = DeclSyntax("@available(*, deprecated, renamed: \"destination\")\nvar destinations: Destination? { get { destination } set { destination = newValue }}")

        return [
            destinationObservationDecl,
            compatibilityAccessorDecl,
            modelActiveVarDecl
        ]
    }

}

// MARK: - Errors

enum NavigableMacroError: Error, CustomStringConvertible {

    case notAnEnum
    case noParentClass
    case parentNotObservable
    case outsideReactor
    case string(String)

    var description: String {
        switch self {
        case .notAnEnum:
            "Navigable macro must be applied to an enum."

        case .noParentClass:
            "Navigable macro must be applied to a class that conforms to Reactor."

        case .parentNotObservable:
            "Parent class is not marked @Observable."

        case .outsideReactor:
            "Parent class doesn't conform to Reactor."

        case .string(let string):
            "\(string)"
        }
    }

}
