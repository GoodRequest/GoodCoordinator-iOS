//
//  AppDelegate.swift
//  NavigationApp
//
//  Created by Filip Šašala on 27/04/2023.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        print("Delegate did finish launching")
        return true
    }

}
