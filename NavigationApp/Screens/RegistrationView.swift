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

struct RegistrationView: View {

    @State private var agrees: Bool = false
    @EnvironmentObject<NavigationObject> var navigation

    var model: RegistrationModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, \(model.hashValue)")

            Spacer().frame(height: 100)

            Toggle(isOn: $agrees, label: {
                Text("Sell my soul")
            })
            Button(action: {
                print("Registering...")

                navigation.set(NavigationPath([HomeModel()]))
            }, label: {
                agrees ? Text("Yes!") : Text("No")
            })
            Button(action: {
                print("Going back")

                navigation.pop()
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
