//
//  LoginView.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import SwiftUI
import StoreKit

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

    typealias Content = Self
    typealias Data = LoginModel

    @State private var username: String = ""
    @State private var password: String = ""

    typealias Model = LoginModel
    @ObservedObject var viewModel: Model

    init(model: LoginModel) {
        self.viewModel = model
    }

    var id: String {
        "loginView"
    }

    @EnvironmentObject var router: Router<AppCoordinator>

    var body: some View {
        VStack {
            Text("Login view")

            TextField("Username", text: $username)
            TextField("Password", text: $password)

            Spacer().frame(height: 40)

            Group {
                Button(action: {
//                    router.coordinator.route(to: \.push).route(to: \.push, "")
                    router.coordinator.route(to: \.push).route(to: \.present).route(to: \.push)
                }, label: {
                    Text("Push next")
                })

                Button(action: {
                    router.coordinator.route(to: \.present).route(to: \.push, "")
//                    router.coordinator.route(to: \.push).route(to: \.present)
                }, label: {
                    Text("Present other")
                })

                Button(action: {
                    router.coordinator.route(to: \.push)
                }, label: {
                    Text("Switch to home")
                })
            }
            .padding()
        }
        .padding()
        .navigationTitle("Dobry vecer")
    }

}

struct LoginView_Previews: PreviewProvider {

    static var previews: some View {
        LoginView(model: LoginModel()).makeView()
    }

}
