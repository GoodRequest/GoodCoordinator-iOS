//
//  CoordinatorConfiguration.swift
//  GoodCoordinator_v3
//
//  Created by Matus Klasovity on 11/06/2025.
//


import Foundation

@MainActor
public struct CoordinatorConfiguration: Sendable {

    private init() {}

    public static var logger: CoordinatorLogger? = nil

}
