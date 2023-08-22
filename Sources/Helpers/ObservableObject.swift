//
//  ObservableObject.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 22/08/2023.
//

import Combine

public protocol ObjectWillChangeObservable:
    ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {}
