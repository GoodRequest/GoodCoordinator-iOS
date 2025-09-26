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

    // MARK: - Test invocation

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

    // MARK: - Diagnostics

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

    // MARK: - NavigationRoot

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

    // MARK: - Navigable

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

                    public struct AllCasePaths: CasePaths.CasePathReflectable, Swift.Sendable, Swift.Sequence {
                        public subscript(root: Destination) -> CasePaths.PartialCaseKeyPath<Destination> {
                            if root.is(\.home) {
                                return \.home
                            }
                            return \.never
                        }
                        public var home: CasePaths.AnyCasePath<Destination, Void> {
                            ._$embed({
                                    Destination.home
                                }) {
                                guard case .home = $0 else {
                                    return nil
                                }
                                return ()
                            }
                        }
                        public func makeIterator() -> Swift.IndexingIterator<[CasePaths.PartialCaseKeyPath<Destination>]> {
                            var allCasePaths: [CasePaths.PartialCaseKeyPath<Destination>] = []
                            allCasePaths.append(\.home)
                            return allCasePaths.makeIterator()
                        }
                    }
                    public static var allCasePaths: AllCasePaths { AllCasePaths() }
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

                        withMutation(keyPath: \.destination) {
                            #router.set(self, destination: newValue)
                        }
                    }
                }

                @available(*, deprecated, renamed: "destination")
                var destinations: Destination? {
                    get {
                        destination
                    }
                    set {
                        destination = newValue
                    }
                }

                var _modelActive: Bool = false
            }

            extension Model.Destination: DestinationCaseNavigable {
            }
            """#
        }
    }

}
