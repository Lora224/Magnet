import Foundation
import SwiftUI
import SwiftData

@Model
final class user: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var profilePictureURL: String?
    var families: [String]
    var appleID: String

    init(id: UUID = UUID(), name: String, profilePictureURL: String, families: [String], appleID: String) {
        self.id = id
        self.name = name
        self.profilePictureURL = profilePictureURL
        self.families = families
        self.appleID = appleID
    }
}
