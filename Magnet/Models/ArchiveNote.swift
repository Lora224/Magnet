//
//  ArchiveNote.swift
//  Magnet
//
//  Created by Siddharth Wani on 3/6/2025.
//

import SwiftUI
import FirebaseFirestoreCombineSwift   // gives us @DocumentID
import FirebaseFirestore

struct ArchiveNote: Identifiable, Codable, Hashable {
    @DocumentID var id      : String?      // Firestore document ID
    var text            : String          // e.g. "Anna's Birthday 🎂"
    var date   : Timestamp       // Firestore Timestamp instead of Date
    var cardColor        : HexColor        // stored as hex string
    
    init(id: String? = nil,
         text: String,
         date: Date,
         cardColor: HexColor) {
        self.id            = id
        self.text          = text
        self.date = Timestamp(date: date)
        self.cardColor      = cardColor
    }
}

 

