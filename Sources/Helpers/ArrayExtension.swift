//
//  ArrayExtension.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 31/07/2023.
//

internal extension Array {

    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }

}
