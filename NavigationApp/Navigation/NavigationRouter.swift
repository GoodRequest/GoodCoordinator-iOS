//
//  NavigationRouter.swift
//  NavigationApp
//
//  Created by Filip Šašala on 09/05/2023.
//

import SwiftUI

struct NavigationRouter: Router {

    @Environment(\.routingTree) var routingTree
    @State private var path: NavigationPath = NavigationPath()

    var id: UUID = UUID()

    private var content: any Screen
    private var navigationDestinations: [UUID: Binding<Bool>] = [:]

    var body: some View {
        NavigationStack(
            path: $path,
            root: { buildView() }
        )
    }

    init(content: () -> some Screen) {
        self.content = content()
    }

    private func buildView() -> some View {
        var contentView = AnyView(content)
        navigationDestinations.forEach { id, binding in
            contentView = AnyView(contentView.navigationDestination(
                isPresented: binding,
                destination: {
                    Text("asdf")
                }
            ))
        }
        return contentView
    }

//    private func makePathFromTree() -> NavigationPath {
//        var navigationPath = NavigationPath()
//
//        var currentChild = routingTree
//        while let child = currentChild.firstChild {
//            navigationPath.append(child.value)
//            currentChild = child
//        }
//        return navigationPath
//    }

}

extension NavigationRouter {

    func push<Content: Screen>(_ step: Push<Content>) {
         routingTree.lastLeaf.add(child: Node(step))
    }

}

struct TabRouter: Router {

    var body: some View {
        EmptyView()
    }

}

struct SimpleRouter<S>: Router where S: Screen {

    private let content: S

    var body: some View {
        content
    }

    init(content: () -> S) {
        self.content = content()
    }

}
