//
//  HomeView.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI

struct HomeModel: Hashable {

    // Nothing™

}

struct HomeView: Screen {

    @EnvironmentObject var router: NavigationRouter<AppCoordinator>

    var body: some View {
        VStack {
            Text("Home screen")

            Button(action: {
//                router.route(to: \.uiKit, ())
                router.coordinator.route(to: \.registration)
            }, label: {
                Text("Push more")
            })

            Button(action: {
                // appContext.switch(to: .login)

//                router.coordinator.popToRoot()
                router.coordinator.route(to: \.root)
            }, label: {
                Text("Go to login")
            })
            .padding(.vertical, 20)
        }
        .padding()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

}

struct HomeView_Previews: PreviewProvider {

    static var previews: some View {
        HomeView()
    }

}
