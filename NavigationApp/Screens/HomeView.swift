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

struct HomeView: View, Screen {

    @EnvironmentObject var router: Router<AppCoordinator>

    var body: some View {
        VStack {
            Text("Home screen")

            Group {
                Button(action: {
                    router.coordinator.route(to: \.push)
                }, label: {
                    Text("Push more")
                })

                Button(action: {
                    router.coordinator.pop()
                }, label: {
                    Text("Pop")
                })

                Button(action: {
                    router.coordinator.popToRoot()
                }, label: {
                    Text("Pop to root")
                })
            }
            .padding()

            Button(action: {
                router.coordinator.route(to: \.present)
            }, label: {
                Text("Present other")
            })
        }
        .padding()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

}

struct HomeView_Previews: PreviewProvider {

    static var previews: some View {
        HomeView().makeView()
    }

}
