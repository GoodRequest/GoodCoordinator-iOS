//
//  CoordinatorLogger.swift
//  GoodCoordinator_v3
//
//  Created by Matus Klasovity on 11/06/2025.
//

import Foundation

public enum LogLevel {
    case debug
}

public protocol CoordinatorLogger: Sendable {

    func logCoordinatorEvent(_ message: Any, level: LogLevel, fileName: String, lineNumber: Int)

}
