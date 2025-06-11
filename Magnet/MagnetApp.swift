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
import FirebaseStorage

import Firebase
import FirebaseAppCheck

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



@main
struct MagnetApp: App {
@StateObject private var stickyManager = StickyDisplayManager()
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
      WindowGroup {
        NavigationStack {
          Login()
        }
        .environmentObject(stickyManager)
      }
    .modelContainer(for: [
     // StickyNote.self,
    //  Payload.self,
     // Family.self,
      User.self
    ])
  }
}


