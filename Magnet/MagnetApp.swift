//
//  MagnetApp.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

import SwiftUI
import FirebaseCore
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


@main
struct MagnetApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
          Login()
    }
    .modelContainer(for: [
      StickyNote.self,
      Payload.self,
      Family.self,
      User.self
    ])
  }
}

