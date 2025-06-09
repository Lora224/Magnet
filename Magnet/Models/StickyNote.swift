import SwiftData
import Foundation
import Foundation
/* will be stored as string in db */
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

/*for image/video type, text is the caption*/
/*for voice type, text is the voice to text content*/
/*for text type, text is the content*/


struct StickyNote: Identifiable, Codable {
    var id: UUID
    var senderID: String
    var familyID: String
    var type: MediaType
    var timeStamp: Date
    var seen: [String: ReactionType?]
    var text: String?
    var payloadURL: String?

    init(
        id: UUID = .init(),
        senderID: String,
        familyID: String,
        type: MediaType,
        timeStamp: Date = .init(),
        seen: [String: ReactionType?] = [:],
        text:String,
        payloadURL: String?
    ) {
        self.id = id
        self.senderID = senderID
        self.familyID = familyID
        self.type = type
        self.timeStamp = timeStamp
        self.seen = seen
        self.text = text
        self.payloadURL = payloadURL

    }
}


