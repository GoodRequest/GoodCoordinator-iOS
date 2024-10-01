//
//  MutableDestination.swift
//  GoodCoordinator_v3
//
//  Created by Filip Šašala on 20/09/2024.
//

struct MutableDestination {

    var destination: AnyDestination?
    var mutator: (AnyDestination?) -> Void

}
