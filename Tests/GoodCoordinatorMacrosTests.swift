//
//  MacroCollectionTests.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 09/09/2024.
//

import MacroTesting
import XCTest

@testable import GoodCoordinatorMacros

final class MacroCollectionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(
            macros: [
                "Navigable": Navigable.self,
                "NavigationRoot": NavigationRoot.self
            ]
        ) {
            super.invokeTest()
        }
    }

    func testNavigableMacroExpansion() {
        assertMacro(record: .all) {
            """
            @Observable final class Model: Reactor {
                @Navigable enum Destination: Tabs {
            
                    static let initialDestination = .home
            
                    case home, profile
                    case login
                }
            }
            """
        } diagnostics: {
            """
            @Observable final class Model: Reactor {
                @Navigable enum Destination: Tabs {
                ┬─────────
                ╰─ 🛑 Navigable macro must be applied to a class that conforms to Reactor.

                    static let initialDestination = .home

                    case home, profile
                    case login
                }
            }
            """
        }
    }

    func testNavigableMacroExpansionStruct() {
        assertMacro(record: .never) {
            """
            @Navigable struct Destination {}
            """
        } diagnostics: {
            """
            @Navigable struct Destination {}
            ┬─────────
            ╰─ 🛑 Navigable macro must be applied to an enum.
            """
        }
    }

    func testNavigableMacroExpansionEnumNoParent() {
        assertMacro(record: .never) {
            """
            @Navigable enum Destination {
                case home
                case profile
            }
            """
        } diagnostics: {
            """
            @Navigable enum Destination {
            ┬─────────
            ╰─ 🛑 Navigable macro must be applied to a class that conforms to Reactor.
                case home
                case profile
            }
            """
        }
    }

    func testNavigableMacroExpansionEnumParentNotObservable() {
        assertMacro(record: .all) {
            """
            final class Model: Reactor {
                @Navigable enum Destination: Tabs {
            
                    static let initialDestination = .home
            
                    case home, profile
                    case login
                }
            }
            """
        } diagnostics: {
            """
            final class Model: Reactor {
                @Navigable enum Destination: Tabs {
                ┬─────────
                ╰─ 🛑 Navigable macro must be applied to a class that conforms to Reactor.

                    static let initialDestination = .home

                    case home, profile
                    case login
                }
            }
            """
        }
    }

    func testNavigationRootMacroExpansion() {
        assertMacro(record: .never) {
            """
            @NavigationRoot struct MainWindow: View {
                var body: some View {
                    Text("asdf")
                }
            }
            """
        } expansion: {
            """
            struct MainWindow: View {
                var body: some View {
                    Text("asdf")
                }

                @MainActor static let __navigationPath: Router = Router()
            }

            @MainActor internal func __module_rootNavigationPath() -> Router {
                return MainWindow.__navigationPath
            }
            """
        }
    }

}
