//
//  Models.swift
//

import Foundation
import SwiftUI
import FirebaseFirestoreCombineSwift   // gives us @DocumentID
import FirebaseFirestore

/*Example:
 
 let note = StickyNote(senderID:  user.id!,
                       familyID:  fam.id!,
                       payload:   .voice(remoteURL:"voice/a123.m4a", transcript:"Hi Ma!"),
                       colorHex:  HexColor("#D1E9F6"),
                       createdAt: Timestamp())      // or serverTimestamp in rules

 try Firestore.firestore()
      .collection("families")
      .document(fam.id!)
      .collection("notes")
      .document().setData(from: note)
 */


// ─────────────────────────────────────────────────────────────
// MARK: - Helpers
// ─────────────────────────────────────────────────────────────

/// Convert a hex string like “#D1E9F6” to/from SwiftUI `Color`.
struct HexColor: Codable, Hashable {
    var hex: String            // persisted

    var color: Color { Color(hex: hex) }

    init(_ hex: String) { self.hex = hex }
}

// Small Color extension for convenience (not encoded)
private extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: .alphanumerics.inverted))
        var int: UInt64 = 0; _ = scanner.scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double((int      ) & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
// ─────────────────────────────────────────────────────────────
// MARK: - Sticky Note
// ─────────────────────────────────────────────────────────────

enum MediaKind: String, Codable {
    case text
    case image
    case video
    case voice
}

/// Holds the actual payload; encoded as a plain dictionary in Firestore.
enum StickyPayload: Codable, Hashable {
    case text(                 body: String)
    case image(remoteURL:      String)        // Firebase Storage / https link
    case video(remoteURL:      String, poster: String?)
    case voice(remoteURL:      String, transcript: String)

    // Coding keys
    private enum Key: CodingKey { case kind
        case body, remoteURL, poster, transcript
    }

    // MARK: Decodable
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Key.self)
        let kind = try c.decode(MediaKind.self, forKey: .kind)
        switch kind {
        case .text:
            self = .text(body: try c.decode(String.self, forKey: .body))
        case .image:
            self = .image(remoteURL: try c.decode(String.self, forKey: .remoteURL))
        case .video:
            self = .video(remoteURL: try c.decode(String.self, forKey: .remoteURL),
                          poster:    try c.decodeIfPresent(String.self, forKey: .poster))
        case .voice:
            self = .voice(remoteURL: try c.decode(String.self,  forKey: .remoteURL),
                          transcript: try c.decode(String.self, forKey: .transcript))
        }
    }

    // MARK: Encodable
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: Key.self)
        switch self {
        case .text(let body):
            try c.encode(MediaKind.text, forKey: .kind)
            try c.encode(body,          forKey: .body)
        case .image(let url):
            try c.encode(MediaKind.image, forKey: .kind)
            try c.encode(url,             forKey: .remoteURL)
        case .video(let url, let poster):
            try c.encode(MediaKind.video, forKey: .kind)
            try c.encode(url,             forKey: .remoteURL)
            try c.encodeIfPresent(poster, forKey: .poster)
        case .voice(let url, let tx):
            try c.encode(MediaKind.voice, forKey: .kind)
            try c.encode(url,             forKey: .remoteURL)
            try c.encode(tx,              forKey: .transcript)
        }
    }
}



struct StickyNote: Identifiable, Codable, Hashable {
    @DocumentID var id : String?

    // Foreign keys
    var senderID : String                // User doc ID
    var familyID : String                // Family doc ID (board)

    // Payload
    var payload  : StickyPayload

    // Meta
    var cardColor : HexColor              // pastel background
    var createdAt: Timestamp             // serverTimestamp() on write

    // Reactions can be embedded or a sub-collection; here we embed.
    var reactions: [Reaction] = []
}
