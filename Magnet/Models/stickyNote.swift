//
//  stickyNote.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//
//
//  SwiftData models for StickyNote, Payload, and related types.
//  Make sure your deployment target is iOS 17 / macOS 14 or later.
//  Also add a `.swiftdata` model file to your project so SwiftData can generate the SQLite schema.
//

import SwiftData
import SwiftUI
import Foundation


// ────────────────────────────────────────────────────────────────
// MARK: – MediaType & ReactionType Enums
// ────────────────────────────────────────────────────────────────

/// Four possible media types for a StickyNote.
enum MediaType: String, Codable {
    case image
    case video
    case text
    case audio
}

/// Emoji reactions a user can leave on a StickyNote.
enum ReactionType: String, Codable {
    case smile
    case liked
    case clap
}

// ────────────────────────────────────────────────────────────────
// MARK: – Payload Model
// ────────────────────────────────────────────────────────────────

/// A single payload attached to a StickyNote (either text or a URL).
struct Payload: Identifiable, Codable {
    let id: UUID
    var text: String?
    var url: String?
    
    init(
        id: UUID = .init(),
        text: String? = nil,
        url: String? = nil
    ) {
        self.id = id
        self.text = text
        self.url = url
    }
}

// ────────────────────────────────────────────────────────────────
// MARK: – StickyNote Model
// ────────────────────────────────────────────────────────────────

/// A single “sticky note” that lives within a family/board.
/// Designed for local use now, but fields match what Firestore would store.
struct StickyNote: Identifiable, Codable {
    let id: UUID
    var senderID: String               // ID of the user who created this note
    var familyID: String               // ID of the family/board this belongs to
    var type: MediaType                // image, video, text, or audio
    var timeStamp: Date                // when it was created
    
    /// Maps each userID → their ReactionType (or nil if they saw without reacting).
    /// e.g. ["user123": .smile, "user456": nil]
    var seen: [String: ReactionType?]
    
    /// An array of payload objects (text or URL).
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
