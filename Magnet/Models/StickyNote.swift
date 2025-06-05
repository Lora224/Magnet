import SwiftData
import Foundation
import Foundation

enum MediaType: String, Codable {
    case image
    case video
    case text
    case audio
}

enum ReactionType: String, Codable {
    case smile
    case liked
    case clap
}

@Model
final class StickyNote: Identifiable {
    var id: UUID
    var senderID: String
    var familyID: String
    var type: MediaType
    var timeStamp: Date
    var seen: [String: ReactionType?]
    var payloads: [Payload]

    init(
        id: UUID = .init(),
        senderID: String,
        familyID: String,
        type: MediaType,
        timeStamp: Date = .init(),
        seen: [String: ReactionType?] = [:],
        payloads: [Payload] = []
    ) {
        self.id = id
        self.senderID = senderID
        self.familyID = familyID
        self.type = type
        self.timeStamp = timeStamp
        self.seen = seen
        self.payloads = payloads
    }
}

