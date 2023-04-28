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

    @EnvironmentObject<CurrentContext<AvailableContexts>> var appContext

    var body: some View {
        VStack {
            Text("Home screen")

            Button(action: {
                appContext.switch(to: .login)
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
