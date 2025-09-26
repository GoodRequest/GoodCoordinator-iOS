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
        .package(url: "https://github.com/goodrequest/GoodReactor.git", branch: "feature/typeerasure"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.3")),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0" ..< "603.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths.git", .upToNextMajor(from: "1.7.2")),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.6.4")
    ],
    targets: [
        .target(
            name: "GoodCoordinator",
            dependencies: [
                .target(name: "GoodCoordinatorMacros"),
                .product(name: "GoodReactor", package: "GoodReactor"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "CasePathsCore", package: "swift-case-paths")
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
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "GoodCoordinatorTests",
            dependencies: [
                .target(name: "GoodCoordinator"),
                .product(name: "MacroTesting", package: "swift-macro-testing")
            ],
            path: "./Tests"
        )
    ]
)

