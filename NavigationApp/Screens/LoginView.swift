//
//  LoginView.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI

final class LoginModel: ObservableObject, Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(UUID())
    }

    static func == (lhs: LoginModel, rhs: LoginModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    // Nothing™

}

struct LoginView: Screen {

    @State private var username: String = ""
    @State private var password: String = ""

    typealias Model = LoginModel
    @ObservedObject var viewModel: Model

    init(model: LoginModel) {
        self.viewModel = model

        self.ok()
    }

    // @EnvironmentObject<NavigationController> var navigation

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
                // navigation.pop()
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
        LoginView(model: LoginModel())
    }

}
