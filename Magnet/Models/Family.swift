//import SwiftData
//import SwiftUI
//
//@Model
//class Family {
//    var id: UUID
//    var name: String
//    var inviteURL: String
//    var memberIDs: [String]
//    var profilePic: Data?
//    var red: Double
//    var green: Double
//    var blue: Double
//
//    init(
//        id: UUID = UUID(),
//        name: String = "Family 1",
//        inviteURL: String,
//        memberIDs: [String],
//        red: Double = 1.0,
//        green: Double = 0.96,
//        blue: Double = 0.85,
//        profilePic: Data? = nil
//        
//    ) {
//        self.id = id
//        self.name = name
//        self.inviteURL = inviteURL
//        self.memberIDs = memberIDs
//        self.profilePic = profilePic
//        self.red = red
//        self.green = green
//        self.blue = blue
//    }
//
//    var swiftUIColor: Color {
//        Color(red: red, green: green, blue: blue)
//    }
//}

import Foundation

struct Family: Identifiable {
    var id: String // familyID == documentID
    var name: String
    var inviteURL: String
    var memberIDs: [String]
    var red: Double
    var green: Double
    var blue: Double
    var profilePic: Data?
    var emoji: String
}
