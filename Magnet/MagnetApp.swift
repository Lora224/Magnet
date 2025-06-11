//
//  MagnetApp.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

import SwiftUI
import FirebaseCore
import SwiftData
import Firebase
import FirebaseAppCheck
import FirebaseAuth
import FirebaseStorage


class AppDelegate: NSObject, UIApplicationDelegate {
//    override init() {
//        // ✅ 🔒 Register Debug provider FIRST
//        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
//        super.init()
//    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        print("✅ FirebaseApp configured successfully in AppDelegate")
        return true
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn = false
}


@main
struct MagnetApp: App {
    @StateObject var appState: AppState
    @StateObject var authManager = AuthManager()

    // register app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("✅ FirebaseApp configured in MagnetApp.init()")
        }

        let initialAppState = AppState()

        if Auth.auth().currentUser != nil {
            initialAppState.isLoggedIn = true
            print("✅ User is already logged in → show MainView")
        } else {
            initialAppState.isLoggedIn = false
            print("✅ No user → show Login")
        }

        _appState = StateObject(wrappedValue: initialAppState)
    }

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                MainView()
                    .environmentObject(appState)
                    .environmentObject(authManager)
            } else {
                Login()
                    .environmentObject(appState)
                    .environmentObject(authManager)
            }
        }
        .modelContainer(for: [
            User.self
        ])
    }
}
