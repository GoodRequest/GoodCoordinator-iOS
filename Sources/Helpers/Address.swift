//
//  Address.swift
//  NavigationApp
//
//  Created by Filip Šašala on 26/07/2023.
//

public func address(of obj: Any) -> String {
    let type = type(of: obj)
    let address = withUnsafePointer(to: obj, { pointer in
        return pointer.debugDescription
    })

    return "\(type) \(address)"
}
