//
//  TabStep.swift
//  GoodCoordinator
//
//  Created by Filip Šašala on 08/08/2023.
//

import SwiftUI

public struct TabStep<CoordinatorType: TabCoordinator, ScreenType: Screen>: RouteType {

    public typealias InputType = Void
    
    public var options: Label<Text, Image>
    public var screenBuilder: ScreenBuilder<CoordinatorType, InputType, ScreenType>

    public init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, InputType, ScreenType>) {
        self.screenBuilder = wrappedValue
        self.options = Label("Tab", systemImage: "app")
    }
    
    public init(wrappedValue: @escaping ScreenBuilder<CoordinatorType, Void, ScreenType>, options: Label<Text, Image>) {
        self.screenBuilder = wrappedValue
        self.options = options
    }

    public func apply(coordinator: CoordinatorType, input: InputType) -> ScreenType {
        let tabs: [Any] = [coordinator.tab1, coordinator.tab2, coordinator.tab3, coordinator.tab4, coordinator.tab5]
        
        let index = tabs.firstIndex { $0 is Self } ?? 0
        coordinator.selectTab(index)
        
        return prepareScreen(coordinator: coordinator, input: input)
    }
    
}
