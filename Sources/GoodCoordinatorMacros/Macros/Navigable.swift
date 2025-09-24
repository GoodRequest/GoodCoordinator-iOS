//
//  Navigable.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 07/09/2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct Navigable: ExtensionMacro, PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let extensionDeclaration = DeclSyntax("extension \(type.trimmed): DestinationCaseNavigable {}")

        return [extensionDeclaration.as(ExtensionDeclSyntax.self)!]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // _DestinationsActive
        guard let enumSyntax = declaration.as(EnumDeclSyntax.self) else {
            throw NavigableMacroError.notAnEnum
        }

        let enumMembers = enumSyntax.memberBlock.members
        let rawCases: [TokenSyntax] = enumMembers.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }.reduce(into: [], { result, elementList in
            let enumCaseElements = elementList.elements.reduce(into: [], { result, element in
                result.append(element)
            })
            result.append(contentsOf: enumCaseElements.map { $0.name })
        })

        let enumCases = rawCases.map { $0.text }

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

        let enclosingClassName = enclosingClassDecl.name.text

        let classConformances = "__ReactorDirectWritable"
        let classHeader = "@Observable @MainActor final class _DestinationsActive: \(classConformances) {"
        let classFields = "fileprivate weak var reactor: \(enclosingClassName)?"
        let classFooter = "}"

        let classBody = enumCases.map { name in
            """
            var \(name): Bool {
                get {
                    guard let reactor else { return false }
                    if case .\(name) = reactor.destination {
                        return true
                    } else {
                        return false
                    }
                }
                set {
                    if let reactor, !newValue {
                        if case .\(name) = reactor.destination {
                            reactor.destination = nil
                        }
                    }
                }
            }
            """
        }.joined(separator: "\n")

        let destinationsActiveDecl = DeclSyntax("\(raw: classHeader)\n\(raw: classFields)\n\(raw: classBody)\n\(raw: classFooter)")

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
                
                destinations.reactor = self
                withMutation(keyPath: \\.destination) {
                    #router.set(self, destination: newValue)
                }
            }
            _modify {
                access(keyPath: \\.destination)
                _$observationRegistrar.willSet(self, keyPath: \\.destination)
                defer {
                    _$observationRegistrar.didSet(self, keyPath: \\.destination)
                }
                yield &destination
            }
        }
        """)
        let destinationObservationDecl = DeclSyntax("var destination: Destination? \(raw: observationTracked)")

        // var destinations
        let destinationsDecl = DeclSyntax("var destinations = _DestinationsActive()")

        // var _modelActive
        let modelActiveVarDecl = DeclSyntax("var _modelActive: Bool = false")

        return [
            destinationsActiveDecl,
            destinationObservationDecl,
            destinationsDecl,
            modelActiveVarDecl
        ]
    }

}

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
