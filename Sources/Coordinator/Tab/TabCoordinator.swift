//
//  TabCoordinator.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 07/08/2023.
//

import SwiftUI

public final class TabState: ObservableObject {

    internal weak var parent: (any Coordinator)?

    @Published internal var selected: Int = 0 {
        didSet {
            print("Switch tab: \(selected)")
        }
    }

    public init() {
        print("+ init \(address(of: self))")
    }

    deinit {
        print("- deinit \(address(of: self))")
    }

}

// MARK: - Protocol implementation

public protocol TabCoordinator: Coordinator where State == TabState, Input == Void, Output == Void {
    
    associatedtype Tab1: Screen
    associatedtype Tab2: Screen
    associatedtype Tab3: Screen
    associatedtype Tab4: Screen
    associatedtype Tab5: Screen
    
    var tab1: TabStep<Self, Tab1> { get }
    var tab2: TabStep<Self, Tab2> { get }
    var tab3: TabStep<Self, Tab3> { get }
    var tab4: TabStep<Self, Tab4> { get }
    var tab5: TabStep<Self, Tab5> { get }
    
    init()

}

public extension TabCoordinator where Input == Void {

    init() {
        self.init(())
    }

}

// MARK: - Tab variants

public protocol TabCoordinator2: TabCoordinator where Tab3 == EmptyView, Tab4 == EmptyView, Tab5 == EmptyView {}
public protocol TabCoordinator3: TabCoordinator where Tab4 == EmptyView, Tab5 == EmptyView {}
public protocol TabCoordinator4: TabCoordinator where Tab5 == EmptyView {}
public typealias TabCoordinator5 = TabCoordinator

public extension TabCoordinator where Tab5 == EmptyView {
    
    var tab5: TabStep<Self, Tab5> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    
}

public extension TabCoordinator where Tab4 == EmptyView, Tab5 == EmptyView {
    
    var tab4: TabStep<Self, Tab4> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    var tab5: TabStep<Self, Tab5> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    
}

public extension TabCoordinator where Tab3 == EmptyView, Tab4 == EmptyView, Tab5 == EmptyView {
    
    var tab3: TabStep<Self, Tab3> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    var tab4: TabStep<Self, Tab4> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    var tab5: TabStep<Self, Tab5> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    
}

public extension TabCoordinator where Tab2 == EmptyView, Tab3 == EmptyView, Tab4 == EmptyView, Tab5 == EmptyView {
    
    var tab2: TabStep<Self, Tab2> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    var tab3: TabStep<Self, Tab3> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    var tab4: TabStep<Self, Tab4> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    var tab5: TabStep<Self, Tab5> { TabStep(wrappedValue: { _ in { _ in EmptyView() }}) }
    
}

// MARK: - Protocol requirements

public extension TabCoordinator {

    var parent: (any Coordinator)? {
        get {
            state.parent
        }
        set {
            state.parent = newValue
        }
    }

    init(_ input: Input) {
        self.init()
    }

    func makeView() -> AnyView {
        AnyView(body)
    }

    @ViewBuilder var body: some View {
        TabView(selection: tabBinding(), content: {
            tab1.prepareScreen(coordinator: self, input: ()).makeView().environmentObject(Router(coordinator: self)).tag(0).tabItem({ tab1.options })
            tab2.prepareScreen(coordinator: self, input: ()).makeView().environmentObject(Router(coordinator: self)).tag(1).tabItem({ tab2.options })
            tab3.prepareScreen(coordinator: self, input: ()).makeView().environmentObject(Router(coordinator: self)).tag(2).tabItem({ tab3.options })
            tab4.prepareScreen(coordinator: self, input: ()).makeView().environmentObject(Router(coordinator: self)).tag(3).tabItem({ tab4.options })
            tab5.prepareScreen(coordinator: self, input: ()).makeView().environmentObject(Router(coordinator: self)).tag(4).tabItem({ tab5.options })
        })
    }

}

// MARK: - Protocol constraints

public extension TabCoordinator {

    /// Tab coordinator does not support aborting children
    /// since it is ambiguous, which tab should be discarded.
    func abortChild() {}

    /// Not implemented yet
    func yield(_ output: Output) { fatalError() }

    /// Not implemented yet
    func send(_ output: Output) { fatalError() }

    /// Not implemented yet
    func finish() { fatalError() }

    /// Use @Tab steps instead
    func setRoot(to: any Screen) {
        print("Setting @Root on TabCoordinator is not supported. Use @Tab steps instead.")
    }
    
}

// MARK: - Navigation functions

public extension TabCoordinator {
    
    func selectTab(_ id: Int) {
        state.selected = id
    }
    
}

// MARK: - Helper functions - private

private extension TabCoordinator {
    
    func tabBinding() -> Binding<Int> {
        return Binding(
            get: { [weak state] in
                state?.selected ?? 0
            },
            set: { [weak state] in
                state?.selected = $0
            }
        )
    }
    
}
