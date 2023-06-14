//
//  RouteType.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

// ----------------

protocol RouteType {

    init()

}

// ----------------

struct Root: RouteType {}
struct Push: RouteType {}
struct Present: RouteType {}
