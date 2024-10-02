//
//  Tabs.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 26/09/2024.
//

public protocol Tabs: CaseIterable {

    @MainActor static var initialDestination: Self { get }

}
