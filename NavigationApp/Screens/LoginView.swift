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

struct LoginView: View, Screen {

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
                    let coordinator = router.coordinator
                    print("Address 1: \(address(of: coordinator))")

                    let coordinator2 = coordinator.route(to: \.push)
                    print("Address 2: \(address(of: coordinator2))")

                    let coordinator3 = coordinator2.route(to: \.present)
                    print("Address 3: \(address(of: coordinator3))")

                    let coordinator4 = coordinator3.route(to: \.push)
                    print("Address 4: \(address(of: coordinator4))")
                }, label: {
                    Text("Push next")
                })

                Button(action: {
                    router.coordinator.route(to: \.pushHome)// .route(to: \.push, username)
//                    router.coordinator.route(to: \.push).route(to: \.present)
                }, label: {
                    Text("Present other")
                })

                Button(action: {
                    router.coordinator.route(to: \.switch)
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
