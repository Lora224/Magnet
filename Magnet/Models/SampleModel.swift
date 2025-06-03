//
//  SampleModel.swift
//  Magnet
//
//  Created by Siddharth Wani on 3/6/2025.
//

import SwiftUI

struct User {
    var name: String
    var familyBoards: [FamilyBoard]
}

struct FamilyBoard {
    var name: String
    var stickyItems: [SticktyItem]
    var date: Date
}

struct SticktyItem {
    var content: String
    var image: String
    var audio: String
}




