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

struct RegistrationView: View, Screen {

    @State private var agrees: Bool = false
    var model: RegistrationModel

    @EnvironmentObject var router: Router<OtherCoordinator>

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, \(model.name)")

            Spacer().frame(height: 100)

            Toggle(isOn: $agrees, label: {
                Text("Agree?")
            })

            Button(action: {
                router.coordinator.route(to: \.pushSample)
            }, label: {
                agrees ? Text("Yes!") : Text("No")
            })

            Button(action: {
                router.coordinator.route(to: \.present)
            }, label: {
                Text("Cancel")
            })
        }
        .padding()
        .navigationTitle("Agreements")
    }

}

struct RegistrationView_Previews: PreviewProvider {

    static var previews: some View {
        RegistrationView(model: RegistrationModel(name: "Janko")).makeView()
    }

}
