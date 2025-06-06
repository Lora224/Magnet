//
//  MagnetApp.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

import SwiftUI

import SwiftData




@main
struct MagnetApp: App {


  var body: some Scene {
    WindowGroup {
          MainView()
    }
    .modelContainer(for: [
      StickyNote.self,
      Payload.self,
      Family.self,
      User.self
    ])
  }
}
