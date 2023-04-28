//
//  LoginView.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI

struct LoginModel: Hashable {

    // Nothing™

}

struct LoginView: View {

    @State private var username: String = ""
    @State private var password: String = ""

    @EnvironmentObject<CurrentContext<AvailableContexts>> var appContext

    var body: some View {
        return VStack {
            Text("Login view")

            TextField("Username", text: $username)
            TextField("Password", text: $password)

            Spacer().frame(height: 40)

            NavigationLink(
                value: RegistrationModel(name: username),
                label: { Text("Login") }
            )

            Button(action: {
                appContext.switch(to: .home)
            }, label: {
                Text("Go to home")
            })
            .padding(.vertical, 20)
        }
        .padding()
    }

}

struct LoginView_Previews: PreviewProvider {

    static var previews: some View {
        LoginView()
    }

}
