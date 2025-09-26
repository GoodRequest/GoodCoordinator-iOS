//
//  Exports.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 26/09/2025.
//

@_exported import CasePaths
@_exported import CasePathsCore

public typealias DestinationCaseNavigable = CasePathable & CasePathIterable & Hashable & Sendable
public typealias AnyDestination = (any DestinationCaseNavigable)
