//
//  NavigationStep.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 26/09/2024.
//

import GoodReactor

struct NavigationStep {

    var reactor: AnyReactor?
    var currentDestination: AnyDestination?

    var isTabs: Bool = false
    var isActive: Bool = false
    var mutator: (@MainActor (AnyDestination?) -> Void)?

    nonisolated static func equals(_ lhs: NavigationStep, _ rhs: NavigationStep) -> Bool {
        lhs.reactor == rhs.reactor && lhs.currentDestination?.hashValue == rhs.currentDestination?.hashValue
    }

    nonisolated static func reactorEqualsActive(_ lhs: NavigationStep, _ rhs: NavigationStep) -> Bool {
        lhs.reactor == rhs.reactor && lhs.isActive == rhs.isActive
    }

    nonisolated static func reactorEquals(_ lhs: NavigationStep, _ rhs: NavigationStep) -> Bool {
        lhs.reactor == rhs.reactor
    }

}

extension NavigationStep: CustomStringConvertible {

    var description: String {
        let reactorName = reactor?.description.split(separator: ".").last ?? ""

        if let currentDestination {
            if isActive {
                if isTabs {
                    return "🗂️ \(reactorName).\(currentDestination)"
                } else {
                    return "✅ \(reactorName).\(currentDestination)"
                }
            } else {
                if isTabs {
                    return "⏸️ \(reactorName).\(currentDestination)"
                } else {
                    return "⚠️ \(reactorName).\(currentDestination)"
                }
            }
        } else if !reactorName.isEmpty {
            if isTabs {
                return "⚠️ \(reactorName)"
            } else {
                return "❌ \(reactorName)"
            }
        } else {
            return "🌐"
        }
    }

}
