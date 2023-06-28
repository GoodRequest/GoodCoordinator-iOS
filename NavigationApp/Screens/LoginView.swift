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
                router.coordinator.route(to: \.registration)
            }, label: {
                Text("Present registration")
            })

            Button(action: {
                router.coordinator.route(to: \.home)
            }, label: {
                Text("Switch to home")
            })
            .padding(.vertical, 20)
        }
        .padding()
        .navigationTitle("Dobry vecer")
        .onShake {
            router.coordinator.state.revert()
        }
    }

}

struct LoginView_Previews: PreviewProvider {

    static var previews: some View {
        LoginView(model: LoginModel())
    }

}

fileprivate struct ShakableViewRepresentable: UIViewControllerRepresentable {
    let onShake: () -> ()

    class ShakeableViewController: UIViewController {
        var onShake: (() -> ())?

        override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                onShake?()
            }
        }
    }

    func makeUIViewController(context: Context) -> ShakeableViewController {
        let controller = ShakeableViewController()
        controller.onShake = onShake
        return controller
    }

    func updateUIViewController(_ uiViewController: ShakeableViewController, context: Context) {}
}

fileprivate extension View {

    func onShake(_ block: @escaping () -> Void) -> some View {
        overlay(
            ShakableViewRepresentable(onShake: block).allowsHitTesting(false)
        )
    }

}
