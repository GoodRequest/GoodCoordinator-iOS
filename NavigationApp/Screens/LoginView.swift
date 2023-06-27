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

//    @Environment(\.routingTree) var routingTree
    @EnvironmentObject var router: NavigationRouter<AppCoordinator>

    var body: some View {
        return VStack {
            Text("Login view")

            TextField("Username", text: $username)
            TextField("Password", text: $password)

            Spacer().frame(height: 40)

            Button(action: {

            }, label: {
                Text("Present registration")
            })

            Button(action: {
//                routingTree.lastLeaf.add(child: Node(Push(screen: RegistrationView(model: RegistrationModel(name: username)))))
//                router.root(\.goToHome)
//                router.route(to: \AppCoordinator.home, ())
                router.coordinator.route(to: \.homePush)
            }, label: {
                Text("Push to home")
            })
            .padding(.vertical, 20)
        }
        .padding()
        .navigationTitle("Dobry vecer")
    }

}

struct LoginView_Previews: PreviewProvider {

    static var previews: some View {
        LoginView(model: LoginModel())
    }

}
