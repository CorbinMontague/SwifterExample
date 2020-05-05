//
//  AppDelegate.swift
//  SwifterSpike
//
//  Created by Corbin Montague on 5/5/20.
//  Copyright © 2020 Corbin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Is the app currently running UI tests?
    var isUITesting: Bool {
        return CommandLine.arguments.contains("--uitesting")
    }
    
    /// The localhost port to mock requests against
    var port: Int? {
        // it sucks we have to search through these linearly, but there are never very many CommandLine args when testing anyway.
        for arg in CommandLine.arguments {
            if arg.hasPrefix("--port") {
                let portString = String(arg.suffix(4))
                return Int(portString)
            }
        }
        return nil
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

