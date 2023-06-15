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

struct HomeView: View {

    @EnvironmentObject var router: NavigationRouter<AppCoordinator>

    var body: some View {
        VStack {
            Text("Home screen")

            Button(action: {
                router.route(to: \.home, ())
            }, label: {
                Text("Push more")
            })

            Button(action: {
                // appContext.switch(to: .login)

                router.coordinator.popToRoot()
            }, label: {
                Text("Go to login")
            })
            .padding(.vertical, 20)
        }
        .padding()
    }

}

struct HomeView_Previews: PreviewProvider {

    static var previews: some View {
        HomeView()
    }

}
