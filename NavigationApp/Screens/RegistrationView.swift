//
//  RegistrationView.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI

struct RegistrationModel: Hashable {

    let name: String

}

struct RegistrationView: Screen {

    typealias Content = Self
    typealias Data = RegistrationModel

    var id: String {
        "registrationView"
    }

    @State private var agrees: Bool = false

    var model: RegistrationModel

    @EnvironmentObject var router: NavigationRouter<AppCoordinator>

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, \(model.hashValue)")

            Spacer().frame(height: 100)

            Toggle(isOn: $agrees, label: {
                Text("Agree?")
            })
            Button(action: {
                print("Registering...")

                // navigation.set(NavigationPath([HomeModel()]))
                router.coordinator.route(to: \.registration)
            }, label: {
                agrees ? Text("Yes!") : Text("No")
            })
            Button(action: {
                print("Going back")

                router.coordinator.pop()
            }, label: {
                Text("Cancel")
            })
        }
        .padding()
    }

}

struct RegistrationView_Previews: PreviewProvider {

    static var previews: some View {
        RegistrationView(model: RegistrationModel(name: "Janko"))
    }

}
