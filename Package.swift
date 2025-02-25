// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "GoodCoordinator_v3",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "GoodCoordinator",
            targets: ["GoodCoordinator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/goodrequest/GoodReactor.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.3")),
        .package(url: "https://github.com/sjavora/swift-syntax-xcframeworks.git", from: "600.0.1"),
    ],
    targets: [
        .target(
            name: "GoodCoordinator",
            dependencies: [
                .target(name: "GoodCoordinatorMacros"),
                .product(name: "GoodReactor", package: "GoodReactor"),
                .product(name: "Collections", package: "swift-collections")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableUpcomingFeature("BodyMacros"),
                .enableExperimentalFeature("BodyMacros")
            ]
        ),
        .macro(
            name: "GoodCoordinatorMacros",
            dependencies: [
                .product(name: "SwiftSyntaxWrapper", package: "swift-syntax-xcframeworks")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "GoodCoordinatorTests",
            dependencies: [
                .target(name: "GoodCoordinator"),
                .product(name: "SwiftSyntaxWrapper", package: "swift-syntax-xcframeworks")
            ],
            path: "./Tests"
        )
    ]
)
