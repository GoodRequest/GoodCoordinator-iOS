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
        assertMacro(record: .never) {
            """
            struct Model {
                @Navigable enum Destination: Tabs {
            
                    static let initialDestination = .home
            
                    case home, profile
                    case login
                }
            }
            """
        } diagnostics: {
            """
            struct Model {
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
        assertMacro(record: .never) {
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
                ╰─ 🛑 Parent class is not marked @Observable.

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

    func testNavigableDestinationsActiveExpansion() {
        assertMacro(record: .never) {
            """
            @Observable final class Model: Reactor {
                @Navigable enum Destination {
                    case home
                }
            }
            """
        } expansion: {
            #"""
            @Observable final class Model: Reactor {
                enum Destination {
                    case home
                }

                @Observable @MainActor final class _DestinationsActive: __ReactorDirectWritable {
                    fileprivate weak var reactor: Model?
                    var home: Bool {
                        get {
                            guard let reactor else {
                                return false
                            }
                            if case .home = reactor.destination {
                                return true
                            } else {
                                return false
                            }
                        }
                        set {
                            if let reactor, !newValue {
                                if case .home = reactor.destination {
                                    reactor.destination = nil
                                }
                            }
                        }
                    }
                }

                var destination: Destination? {
                    get {
                        defer {
                            _modelActive = true
                        }
                        access(keyPath: \.destination)
                        if !_modelActive {
                            return #router.getOrInsert(for: self)
                        } else {
                            return #router.get(for: self)
                        }
                    }
                    set {
                        if let newValue {
                            reduce(state: &state, event: Event(destination: newValue))
                        }

                        destinations.reactor = self
                        withMutation(keyPath: \.destination) {
                            #router.set(self, destination: newValue)
                        }
                    }
                    _modify {
                        access(keyPath: \.destination)
                        _$observationRegistrar.willSet(self, keyPath: \.destination)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \.destination)
                        }
                        yield &destination
                    }
                }

                var destinations = _DestinationsActive()

                var _modelActive: Bool = false
            }

            extension Model.Destination: DestinationCaseNavigable {
            }
            """#
        }
    }

}
